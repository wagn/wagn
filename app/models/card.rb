# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  require_dependency 'card/query'
  require_dependency 'card/constant'
  require_dependency 'card/set'
  require_dependency 'card/format'

  extend Card::Set
  extend Card::Constant
  extend Wagn::Loader

  cattr_accessor :set_patterns
  @@set_patterns = []

  define_callbacks :approve, :store, :extend

  load_set_patterns
  load_formats
  load_sets

  has_many :revisions, :order => :id
  has_many :references_from, :class_name => :Reference, :foreign_key => :referee_id
  has_many :references_to,   :class_name => :Reference, :foreign_key => :referer_id

  attr_writer :selected_revision_id #writer because read method is in mod (and does not override upon load)
  attr_accessor  :cards, :loaded_left, :nested_edit, # should be possible to merge these concepts
    :comment, :comment_author, :account_args,        # obviated soon
    :update_referencers, :was_new_card,              # wrong mechanisms for these
    :error_view, :error_status                       # yuck

  before_save :approve
  around_save :store
  after_save :extend

  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # DELETE
  # following clearly need to be moved to events.

  def delete
    errors.clear
    Card.transaction do
      if validate_delete
        delete_to_trash
        reset_patterns_if_rule saving=true
        true
      end
    end
  end

  def delete_to_trash
    @trash_changed = true
    self.update_attributes :trash => true
    dependents.each do |dep|
      dep.delete_to_trash
    end
    update_references_on_delete
    expire
  end

  def delete!
    delete or raise Wagn::Oops, "Delete failed: #{errors.full_messages.join(',')}"
  end


  def validate_delete
    if codename
      errors.add :delete, "#{name} is is a system card. (#{codename})\n  Deleting this card would mess up our revision records."
    end
    if type_id== Card::UserID && Card::Revision.find_by_creator_id( self.id )
      errors.add :delete, "Edits have been made with #{name}'s user account.\n  Deleting this card would mess up our revision records."
    end
    if respond_to? :custom_validate_delete
      self.custom_validate_delete
    end

    dependents.each do |dep|
      dep.send :validate_delete
      if dep.errors[:delete].any?
        errors.add(:delete, "can't delete dependent card #{dep.name}: #{dep.errors[:delete]}")
      end
    end
    errors.empty?
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # EVENTS
  # The following events are all currently defined AFTER the sets are loaded and are therefore unexposed to the API.  Not good.  (my fault) - efm

  event :check_perms, :after=>:approve do
    approved? or raise( PermissionDenied.new self )
  end

  event :set_stamper, :before=>:store do #|args|
#    puts "stamper called: #{name}"
    self.updater_id = Account.current_id
    self.creator_id = self.updater_id if new_card?
  end

  event :pull_from_trash, :before=>:store, :on=>:create do
    if trashed_card = Card.find_by_key_and_trash(key, true)
      # a. (Rails way) tried Card.where(:key=>'wagn_bot').select(:id), but it wouldn't work.  This #select
      #    generally breaks on cardsI think our initialization process screws with something
      # b. (Wagn way) we could get card directly from fetch if we add :include_trashed (eg).
      #    likely low ROI, but would be nice to have interface to retrieve cards from trash...
      self.id = trashed_card.id
      @from_trash = @trash_changed = true
      @new_record = false
    end
    self.trash = false
    true
  end

  set_callback :store, :after, :update_ruled_cards, :prepend=>true
  set_callback :store, :after, :process_read_rule_update_queue, :prepend=>true

  event :expire_related, :after=>:store do
    self.expire

    if self.is_hard_template?
      self.hard_templatee_names.each do |name|
        Card.expire name
      end
    end
    # FIXME really shouldn't be instantiating all the following bastards.  Just need the key.
    # fix in id_cache branch
    self.dependents.each       { |c| c.expire }
    self.referencers.each      { |c| c.expire }
    self.name_referencers.each { |c| c.expire }
    # FIXME: this will need review when we do the new defaults/templating system
    #if card.changed?(:content)
  end

  event :store_subcards, :after=>:store do #|args|
    #puts "store subcards"
    @subcards = []
    if cards
      cards.each_pair do |sub_name, opts|
        opts[:nested_edit] = self
        absolute_name = sub_name.to_name.post_cgi.to_name.to_absolute_name cardname
        next if absolute_name.key == key # don't resave self!

        if card = Card[absolute_name]
          card = card.refresh
          card.update_attributes opts
        elsif opts[:content].present? and opts[:content].strip.present?
          opts[:name] = absolute_name
          opts[:loaded_left] = self
          card = Card.create opts
        end
        @subcards << card if card
        if card and card.errors.any?
          card.errors.each do |field, err|
            self.errors.add card.name, err
          end
          raise ActiveRecord::Rollback, "broke commit_subcards"
        end
      end
      cards = nil
    end
    true
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ATTRIBUTE TRACKING
  # we can phase this out and just use "dirty" handling once current content is stored in the cards table
  
  # Because of the way it chains methods, 'tracks' needs to come after
  # all the basic method definitions, and validations have to come after
  # that because they depend on some of the tracking methods.
  tracks :name, :type_id, :content, :comment

  # this method piggybacks on the name tracking method and
  # must therefore be defined after the #tracks call

  def name_with_resets= newname
    newkey = newname.to_name.key
    if key != newkey
      self.key = newkey
      reset_patterns_if_rule # reset the old name - should be handled in tracked_attributes!!
      reset_patterns
    end
    @cardname = nil if name != newname.to_s
    self.name_without_resets = newname.to_s
  end
  alias_method_chain :name=, :resets
  alias cardname= name=


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # VALIDATIONS
  # eventify!

  after_validation do
    begin
      expire_pieces if errors.any?
      true
    rescue Exception => e
      expire_pieces
      raise e
    end
  end

  validate do |card|
    return true if @nested_edit
    return true unless Wagn::Conf[:recaptcha_on] && Card.toggle( card.rule(:captcha) )
    c = Wagn::Conf[:controller]
    return true if (c.recaptcha_count += 1) > 1
    c.verify_recaptcha( :model=>card ) || card.error_status = 449
  end

  validates_each :name do |card, attr, name|
    if card.new_card? && name.blank?
      if autoname_card = card.rule_card(:autoname)
        Account.as_bot do
          autoname_card = autoname_card.refresh
          name = card.name = card.autoname( autoname_card.content )
          autoname_card.content = name  #fixme, should give placeholder on new, do next and save on create
          autoname_card.save!
        end
      end
    end

    cdname = name.to_name
    if cdname.blank?
      card.errors.add :name, "can't be blank"
    elsif card.updates.for?(:name)
      #Rails.logger.debug "valid name #{card.name.inspect} New #{name.inspect}"

      unless cdname.valid?
        card.errors.add :name,
          "may not contain any of the following characters: #{ Card::Name.banned_array * ' ' }"
      end
      # this is to protect against using a plus card as a tag
      if cdname.junction? and card.simple? and Account.as_bot { Card.count_by_wql :right_id=>card.id } > 0
        card.errors.add :name, "#{name} in use as a tag"
      end

      # validate uniqueness of name
      condition_sql = "cards.key = ? and trash=?"
      condition_params = [ cdname.key, false ]
      unless card.new_record?
        condition_sql << " AND cards.id <> ?"
        condition_params << card.id
      end
      if c = Card.find(:first, :conditions=>[condition_sql, *condition_params])
        card.errors.add :name, "must be unique; '#{c.name}' already exists."
      end
    end
  end

  validates_each :content do |card, attr, content|
    if card.new_card? && !card.updates.for?(:content)
      content = card.content = card.content #this is not really a validation.  is the double card.content meaningful?  tracked attributes issue?
    end

    if card.updates.for? :content
      card.reset_patterns_if_rule
      card.send :validate_content, content
    end
  end

  validates_each :current_revision_id do |card, attrib, current_rev_id|
    if !card.new_card? && card.current_revision_id_changed? && current_rev_id.to_i != card.current_revision_id_was.to_i
      card.current_revision_id = card.current_revision_id_was
      card.errors.add :conflict, "changes not based on latest revision"
      card.error_view = :conflict
    end
  end

  validates_each :type_id do |card, attr, type_id|
    # validate on update
    if card.updates.for?(:type_id) and !card.new_card?
      if !card.validate_type_change
        card.errors.add :type, "of #{ card.name } can't be changed; errors changing from #{ card.type_name }"
      end
      if c = card.dup and c.type_id_without_tracking = type_id and c.id = nil and !c.valid?
        card.errors.add :type, "of #{ card.name } can't be changed; errors creating new #{ type_id }: #{ c.errors.full_messages * ', ' }"
      end
    end

    # validate on update and create
    if card.updates.for?(:type_id) or card.new_record?
      # invalid to change type when type is hard_templated
      if rt = card.hard_template and rt.assigns_type? and type_id!=rt.type_id
        card.errors.add :type, "can't be changed because #{card.name} is hard templated to #{rt.type_name}"
      end
    end
  end

  validates_each :key do |card, attr, key|
    if key.empty?
      card.errors.add :key, "cannot be blank"
    elsif key != card.cardname.key
      card.errors.add :key, "wrong key '#{key}' for name #{card.name}"
    end
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # METHODS FOR OVERRIDE
  # eventify!

  def on_type_change()                    end
  def validate_type_change()        true  end
  def validate_content( content )         end

end
