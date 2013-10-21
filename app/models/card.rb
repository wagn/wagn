# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  require_dependency 'card/query'
  require_dependency 'card/constant'
  require_dependency 'card/set'
  require_dependency 'card/format'

  extend Card::Set
  extend Card::Constant
  extend Wagn::Loader

  require_dependency 'card/exceptions'
  include Card::Exceptions

  cattr_accessor :set_patterns
  @@set_patterns = []

  define_callbacks :approve, :terminator=>'result == false'
  define_callbacks :store, :extend

  load_set_patterns
  load_formats
  load_sets

  has_many :revisions, :order => :id
  has_many :references_from, :class_name => :Reference, :foreign_key => :referee_id
  has_many :references_to,   :class_name => :Reference, :foreign_key => :referer_id

  attr_writer :selected_revision_id #writer because read method is in mod (and does not override upon load)
  attr_accessor :action,
    :cards, :loaded_left, :nested_edit, # should be possible to merge these concepts
    :comment, :comment_author, :account_args,        # obviated soon
    :update_referencers,                             # wrong mechanisms for this
    :error_view, :error_status                       # yuck

  before_validation :approve
  around_save :store
  after_save :extend

  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?


  

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # EVENTS
  # The following events are all currently defined AFTER the sets are loaded and are therefore unexposed to the API.  Not good.  (my fault) - efm

  event :check_perms, :after=>:approve do
    approved?  #or raise( PermissionDenied.new self )
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
      @from_trash = true
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

  event :store_subcards, :after=>:store, :on=>:save do #|args|
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



end
