# -*- encoding : utf-8 -*-

require_dependency 'smart_name'

class Card < ActiveRecord::Base

  SmartName.codes= Wagn::Codename
  SmartName.params= Wagn::Conf
  SmartName.lookup= Card
  SmartName.session= proc { Account.current.name }

  has_many :revisions, :order => :id #, :foreign_key=>'card_id'

  attr_accessor :comment, :comment_author, :selected_rev_id,
    :update_referencers, :was_new_card, # seems like wrong mechanisms for these
    :cards, :loaded_left, :nested_edit, # should be possible to merge these concepts
    :error_view, :error_status #yuck

  attr_writer :update_read_rule_list

  before_save :set_stamper, :base_before_save, :set_read_rule, :set_tracked_attributes
  after_save :base_after_save, :update_ruled_cards, :update_queue, :expire_related

  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?

  #~~~~~~  CLASS METHODS ~~~~~~~~~~~~~~~~~~~~~

  class << self
    JUNK_INIT_ARGS = %w{ missing skip_virtual id }

    def cache
      Wagn::Cache[Card]
    end

    def new args={}, options={}
      args = (args || {}).stringify_keys
      JUNK_INIT_ARGS.each { |a| args.delete(a) }
      %w{ type typecode }.each { |k| args.delete(k) if args[k].blank? }
      args.delete('content') if args['attach'] # should not be handled here!

      super args
    end

    ID_CONST_ALIAS = {
      :default_type => :basic,
      :anon         => :anonymous,
      :auth         => :anyone_signed_in,
      :admin        => :administrator
    }

    def const_missing const
      if const.to_s =~ /^([A-Z]\S*)ID$/ and code=$1.underscore.to_sym
        code = ID_CONST_ALIAS[code] || code
        if card_id = Wagn::Codename[code]
          const_set const, card_id
        else
          raise "Missing codename #{code} (#{const}) #{caller*"\n"}"
        end
      else
        super
      end
    rescue NameError
      warn "ne: const_miss #{e.inspect}, #{const}" if const.to_sym==:Card
    end

    def setting name
      Account.as_bot do
        card=Card[name] and !card.content.strip.empty? and card.content
      end
    end

    def path_setting name
      name ||= '/'
      return name if name =~ /^(http|mailto)/
      Wagn::Conf[:root_path] + name
    end

    def toggle val
      val == '1'
    end
  end


  # ~~~~~~ INSTANCE METHODS ~~~~~~~~~~~~~~~~~~~~~

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # INITIALIZATION

  def initialize args={}
    args['name']    = args['name'   ].to_s
    args['type_id'] = args['type_id'].to_i

    args.delete('type_id') if args['type_id'] == 0 # can come in as 0, '', or nil

    @type_args = {
      :type     => args.delete('type'    ),
      :typecode => args.delete('typecode'),
      :type_id  => args[       'type_id' ]
    }

    skip_modules = args.delete 'skip_modules'

    super args # ActiveRecord #initialize

    if tid = get_type_id( @type_args )
      self.type_id_without_tracking = tid
    end

    include_set_modules unless skip_modules
    self
  end

  def get_type_id args={}
    return if args[:type_id] # type_id was set explicitly.  no need to set again.

    type_id = case
      when args[:typecode] ;  code=args[:typecode] and (
                              Wagn::Codename[code] || (c=Card[code] and c.id))
      when args[:type]     ;  Card.fetch_id args[:type]
      else :noop
      end

    case type_id
    when :noop 
    when false, nil
      errors.add :type, "#{args[:type] || args[:typecode]} is not a known type."
      @error_view = :not_found
      @error_status = 404
    else
      return type_id
    end

    if name && t=template
      reset_patterns #still necessary even with new template handling?
      t.type_id
    else
      # if we get here we have no *all+*default -- let's address that!
      DefaultTypeID
    end
  end

  def include_set_modules
    unless @set_mods_loaded
      set_modules.each do |m|
        #warn "ism #{m}"
        singleton_class.send :include, m
      end
      @set_mods_loaded=true
    end
    self
  end

  # reset_mods: resets with patterns in model/pattern

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # STATES

  def new_card?
    new_record? || !!@from_trash
  end

  def known?
    real? || virtual?
  end

  def real?
    !new_card?
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # SAVING

  def assign_attributes args={}, options={}
    if args and newtype = args.delete(:type) || args.delete('type')
      args[:type_id] = Card.fetch_id( newtype )
    end
    reset_patterns

    super args, options
  end

  def set_stamper
    self.updater_id = Account.current_id
    self.creator_id = self.updater_id if new_card?
  end

  after_validation :on => :create do
    pull_from_trash if new_record?
    self.trash = !!trash
    true
  end

  after_validation do
    begin
      raise PermissionDenied.new(self) unless approved?
      expire_pieces if errors.any?
      true
    rescue Exception => e
      expire_pieces
      raise e
    end
  end

  def save
    super
  rescue Exception => e
    expire_pieces
    raise e
  end

  def save!
    super
  rescue Exception => e
    expire_pieces
    raise e
  end

  def base_before_save
    if self.respond_to?(:before_save) and self.before_save == false
      errors.add(:save, "could not prepare card for destruction") #fixme - screwy error handling!!
      return false
    end
  end

  def base_after_save
    save_subcards
    @virtual    = false
    @from_trash = false
    Wagn::Hook.call :after_create, self if @was_new_card
    send_notifications
    true
  rescue Exception=>e
    expire_pieces
    @subcards.each{ |card| card.expire_pieces }
    raise e
  end

  def save_subcards
    @subcards = []
    return unless cards
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
        raise ActiveRecord::Rollback, "broke save_subcards"
      else
        cards = nil
        true
      end
    end
  end

  def pull_from_trash
    return unless key
    return unless trashed_card = Card.find_by_key_and_trash(key, true)
    #could optimize to use fetch if we add :include_trashed_cards or something.
    #likely low ROI, but would be nice to have interface to retrieve cards from trash...
    self.id = trashed_card.id
    @from_trash = @trash_changed = true
    @new_record = false
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # DESTROY

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
    if respond_to? :before_delete
      self.before_delete
    end
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

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # NAME / RELATED NAMES


  # FIXME: use delegations and include all cardname functions
  def simple?()        cardname.simple?                     end
  def junction?()      cardname.junction?                   end

  def left *args
    unless !simple? and updates.for? :name and name_without_tracking.to_name.key == cardname.left_name.key
      #the ugly code above is to prevent recursion when, eg, renaming A+B to A+B+C
      #it should really be testing for any trunk
      Card.fetch cardname.left, *args
    end
  end

  def right *args
    simple? ? nil : Card.fetch( cardname.right, *args )
  end

  def trunk *args
    simple? ? self : left( *args )
  end

  def tag *args
    simple? ? self : Card.fetch( cardname.right, *args )
  end

  def left_or_new args={}
    left args or Card.new args.merge(:name=>cardname.left)
  end

  def dependents
    return [] if new_card?

    if @dependents.nil?
      @dependents = 
        Account.as_bot do
          deps = Card.search( { (simple? ? :part : :left) => name } ).to_a
          deps.inject(deps) do |array, card|
            array + card.dependents
          end
        end
      #Rails.logger.warn "dependents[#{inspect}] #{@dependents.inspect}"
    end
    @dependents
  end

  def repair_key
    Account.as_bot do
      correct_key = cardname.key
      current_key = key
      return self if current_key==correct_key

      if key_blocker = Card.find_by_key_and_trash(correct_key, true)
        key_blocker.cardname = key_blocker.cardname + "*trash#{rand(4)}"
        key_blocker.save
      end

      saved =   ( self.key  = correct_key and self.save! )
      saved ||= ( self.cardname = current_key and self.save! )

      if saved
        self.dependents.each { |c| c.repair_key }
      else
        Rails.logger.debug "FAILED TO REPAIR BROKEN KEY: #{key}"
        self.name = "BROKEN KEY: #{name}"
      end
      self
    end
  rescue
    Rails.logger.info "BROKE ATTEMPTING TO REPAIR BROKEN KEY: #{key}"
    self
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # TYPE

  def type_card
    Card[ type_id.to_i ]
  end

  def typecode # FIXME - change to "type_code"
    Wagn::Codename[ type_id.to_i ]
  end

  def type_name
    return if type_id.nil?
    type_card = Card.fetch type_id.to_i, :skip_modules=>true, :skip_virtual=>true
    type_card and type_card.name
  end

  def type= type_name
    self.type_id = Card.fetch_id type_name
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CONTENT / REVISIONS

  def content
    if new_card?
      template ? template.content : ''
    else
      current_revision.content
    end
  end

  def raw_content
    hard_template ? template.content : content
  end
  
  def selected_rev_id
    @selected_rev_id or ( ( cr = current_revision ) ? cr.id : 0 )
  end

  def current_revision
    #return current_revision || Card::Revision.new
    if @cached_revision and @cached_revision.id==current_revision_id
    elsif ( Card::Revision.cache &&
       @cached_revision=Card::Revision.cache.read("#{cardname.safe_key}-content") and
       @cached_revision.id==current_revision_id )
    else
      rev = current_revision_id ? Card::Revision.find(current_revision_id) : Card::Revision.new()
      @cached_revision = Card::Revision.cache ?
        Card::Revision.cache.write("#{cardname.safe_key}-content", rev) : rev
    end
    @cached_revision
  end

  def previous_revision revision_id
    if revision_id
      rev_index = revisions.find_index do |rev|
        rev.id == revision_id
      end
      revisions[rev_index - 1] if rev_index.to_i != 0
    end
  end

  def revised_at
    (current_revision && current_revision.created_at) || Time.now
  end

  def creator
    Card[ creator_id ]
  end

  def updater
    Card[ updater_id || Card::AnonID ]
  end

  def drafts
    revisions.find(:all, :conditions=>["id > ?", current_revision_id])
  end

  def save_draft( content )
    clear_drafts
    revisions.create :content=>content
  end

  protected

  def clear_drafts # yuck!
    connection.execute %{delete from card_revisions where card_id=#{id} and id > #{current_revision_id} }
  end

  public

  #~~~~~~~~~~~~~~ USER-ISH methods ~~~~~~~~~~~~~~#
  # these should be done in a set module when we have the capacity to address the set of "cards with accounts"
  # in the meantime, they should probably be in a module.

  def among? card_with_acct
    prties = parties
    card_with_acct.each { |auth| return true if prties.member? auth }
    card_with_acct.member? Card::AnyoneID
  end

  def parties
    @parties ||= (all_roles << self.id).flatten.reject(&:blank?)
  end

  def read_rules
    @read_rules ||= begin
      rule_ids = []
      unless id==Card::WagnBotID # always_ok, so not needed
        ( [ Card::AnyoneID ] + parties ).each do |party_id|
          if rule_ids_for_party = self.class.read_rule_cache[ party_id ]
            rule_ids += rule_ids_for_party
          end
        end
      end
      rule_ids
    end
  end

  def all_roles
    if @all_roles.nil?
      @all_roles = if id == AnonID; []
        else
          Account.as_bot do
            if get_roles = fetch(:trait=>:roles) and
                ( get_roles = get_roles.item_cards(:limit=>0) ).any?
              [AuthID] + get_roles.map(&:id)
            else [AuthID]
            end
          end
        end
    end
    #warn "aroles #{inspect}, #{@all_roles.inspect}"
    @all_roles
  end

  def account
    User[ id ]
  end

  def accountable?
    Card.toggle(rule(:accountable)) and
    !account and
    fetch( :trait=>:account, :new=>{} ).ok?( :create)
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # METHODS FOR OVERRIDE
  # pretty much all of these should be done differently -efm

  def post_render( content )     content  end
  def clean_html?()                 true  end
  def collection?()                false  end
  def on_type_change()                    end
  def validate_type_change()        true  end
  def validate_content( content )         end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # MISCELLANEOUS

  #def debug_type() type_id end
  def debug_type() "#{typecode||'no code'}:#{type_id}" end
  #def debug_type() "#{type_name}:#{type_id}" end # this can cause infinite recursion

  def to_s
    "#<#{self.class.name}[#{debug_type}]#{self.attributes['name']}>"
  end

  def inspect
    "#<#{self.class.name}" + "##{id}" +
    "###{object_id}" + #"l#{left_id}r#{right_id}" +
    "[#{debug_type}]" + "(#{self.name})" + #"#{object_id}" +
    #(errors.any? ? '*Errors*' : 'noE') +
    (errors.any? ? "<E*#{errors.full_messages*', '}*>" : '') +
    #"{#{references_expired==1 ? 'Exp' : "noEx"}:" +
    "{#{trash&&'trash:'||''}#{new_card? &&'new:'||''}#{frozen? ? 'Fz' : readonly? ? 'RdO' : ''}" +
    "#{@virtual &&'virtual:'||''}#{@set_mods_loaded&&'I'||'!loaded' }:#{references_expired.inspect}}" +
    '>'
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # INCLUDED MODULES

  include Cardlib

  after_save :after_save_hooks
  # moved this after Cardlib inclusions because aikido module needs to come after Paperclip triggers,
  # which are set up in attach model.  CLEAN THIS UP!!!

  def after_save_hooks # don't move unless you know what you're doing, see above.
    Wagn::Hook.call :after_save, self
  end

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

  def cardname
    @cardname ||= name.to_name
  end

  def autoname name
    if Card.exists? name
      autoname name.next
    else
      name
    end
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # VALIDATIONS



  protected

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
          "may not contain any of the following characters: #{ SmartName.banned_array * ' ' }"
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

  # these old_modules should be refactored out
  require_dependency 'flexmail.rb'
  require_dependency 'google_maps_addon.rb'
  require_dependency 'notification.rb'
end
