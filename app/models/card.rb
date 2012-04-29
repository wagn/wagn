# -*- encoding : utf-8 -*-
class Card < ActiveRecord::Base
  cattr_accessor :cache, :id_cache

  # userstamp methods
  model_stamper # Card is both stamped and stamper
  stampable :stamper_class_name => :card

  #FIXME - need to convert all these to WQL

  belongs_to :trunk, :class_name=>'Card', :foreign_key=>'trunk_id' #, :dependent=>:dependent
  has_many   :right_junctions, :class_name=>'Card', :foreign_key=>'trunk_id'#, :dependent=>:destroy

  belongs_to :tag, :class_name=>'Card', :foreign_key=>'tag_id' #, :dependent=>:destroy
  has_many   :left_junctions, :class_name=>'Card', :foreign_key=>'tag_id'  #, :dependent=>:destroy

  belongs_to :current_revision, :class_name => 'Revision', :foreign_key=>'current_revision_id'
  has_many   :revisions, :order => 'id', :foreign_key=>'card_id'


  attr_accessor :comment, :comment_author, :confirm_rename, :confirm_destroy,
    :cards, :set_mods_loaded, :update_referencers, :allow_type_change,
    :loaded_trunk, :nested_edit, :virtual, :attribute,
    :error_view, :error_status, :selected_rev_id, :attachment_id
    #should build flexible handling for set-specific attributes

  attr_reader :type_args, :broken_type
  
  before_destroy :base_before_destroy
  before_save :set_stamper, :base_before_save, :set_read_rule, :set_tracked_attributes
  after_save :base_after_save, :update_ruled_cards, :reset_stamper
  
  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?

  @@junk_args = %w{ missing skip_virtual id }

  @@id_cache = {}
  def self.reset_id_cache() @@id_cache = {} end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # INITIALIZATION METHODS

  def self.new args={}, options={}
    args = (args || {}).stringify_keys
    @@junk_args.each { |a| args.delete(a) }
    %w{ type typecode }.each { |k| args.delete(k) if args[k].blank? }
    args.delete('content') if args['attach'] # should not be handled here!

    if name = args['name'] and !name.blank?
      if  Card.cache                                       and
          cc = Card.cache.read_local(name.to_cardname.key) and
          cc.type_args                                     and
          args['type']          == cc.type_args[:type]     and
          args['typecode']      == cc.type_args[:typecode] and
          args['type_id']       == cc.type_args[:type_id]  and
          args['loaded_trunk']  == cc.loaded_trunk

        args['type_id'] = cc.type_id
        return cc.send( :initialize, args )
      end
    end
    super args
  end

  def initialize(args={})

    args['name'] = args['name'].to_s
    
    args.delete('type_id') if args['type_id'] == ''
    args['type_id'] = args['type_id'].to_i unless args['type_id'].nil?
    #warn (Rails.logger.debug "initialize #{args.inspect}") if [0, nil, ''].member? args['type_id']
    @type_args = { :type=>args.delete('type'), :typecode=>args.delete('typecode'), :type_id=>args['type_id'] }
    #raise "type_id type ??? #{args.inspect}" if @type_args.values.compact.empty?
    skip_modules = args.delete 'skip_modules'

    #warn Rails.logger.warn("card#initialize #{type_args.inspect}, A: #{args.inspect}") #\n#{caller*"\n"}" if args['name'] == 'Ulysses'
    super args

    if tid = get_type_id(@type_args)
      self.type_id_without_tracking = tid
    end

    include_set_modules unless skip_modules
    self
  end

  def new_card?() new_record? || @from_trash  end
  def known?()    real? || virtual?           end
  def real?()     !new_card?                  end

  def reset_mods() @set_mods_loaded=false     end
  def include_set_modules
    #warn "including set modules for #{name}"
    unless @set_mods_loaded
      sm=set_modules
      #warn "set modules: #{sm.inspect} #{sm.map(&:class)*', '}"
      sm.each {|m| singleton_class.send :include, m }
      @set_mods_loaded=true
    end
    self
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CODENAME

  def codename() id && Card::Codename.codename(id) end

  class << self
    def const_missing(const)
      if const.to_s =~ /^([A-Z]\S*)ID$/ and code=$1.underscore
        if card_id = Card::Codename[code]
          const_set const, card_id
        else raise "Missing codename #{code} (#{const})"
        end
      else super end
    end
  end

  DefaultTypeID = BasicID
  AnonID        = AnonymousID
  AuthID        = AnyoneSignedInID
  AdminID       = AdministratorID

  DefaultTypename = 'Basic'

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CURRENT USER

  @@as_user_id = @@rules_uid = @@user_id = @@user_card = @@user = nil
  cattr_accessor :user_id   # the card id of the current user


  def to_user() User.where(:card_id=>id).first end

  class << self
    def user_id() @@user_id ||= Card::AnonID end
    def user_card()
      (uc=@@user_card and uc.id == user_id) ? uc : @@user_card = Card[user_id]
    end
    def user
      (u=@@user and u.card_id == user_id) ? u : @@user = user_card.to_user
    end

    def user=(user) @@as_user_id=nil; @@user_id = user2id(user)
      #warn "user=#{user.inspect}, As:#{@@as_user_id}, C:#{@@user_id}"; @@user_id
    end

    def user2id(user)
      case user
        when NilClass;   nil
        when User    ;   user.card_id
        when Card    ;   user.id
        when Integer ;   user
        else
          user = user.to_s
          Card::Codename[user] or (cd=Card[user] and cd.id)
      end
    end

    def as(given_user)
      #warn Rails.logger.warn("as #{given_user.inspect}")
      tmp_user = @@as_user_id
      @@as_user_id = user2id(given_user)
      #warn Rails.logger.warn("as user is #{@@as_user_id} (#{tmp_user})")
      @@user_id = @@as_user_id if @@user_id.nil?

      if block_given?
        value = yield
        @@as_user_id = tmp_user
        return value
      else
        #fail "BLOCK REQUIRED with Card#as"
      end
    rescue Exception => e
      Rails.logger.warn("exception #{e.inspect} #{e.backtrace*?\n}")
    end

    @@read_rules = nil

    def among?(authzed) Card[as_user_id].among?(authzed) end
    def as_user_id()    @@as_user_id || @@user_id        end
    def read_rules()    load_as_rules; @@read_rules      end
    def user_roles()    load_as_rules; @@user_roles      end
    def load_as_rules
      if as_user_id != @@rules_uid
        if rules_user_card = as_user_id && Card[as_user_id]
          @@user_roles = rules_user_card.all_roles
          @@read_rules = rules_user_card.read_rules || [1]
          @@rules_uid = rules_user_card.id
        else
          @@user_roles = @@read_rules = @@rules_uid = nil
        end
      end
    end

    def logged_in?() user_id != Card::AnonID end

    def no_logins?()
      c = self.cache
      !c.read('no_logins').nil? ? c.read('no_logins') : c.write('no_logins', (User.count < 3))
    end

    def always_ok?
      #warn Rails.logger.warn("aok? #{as_user_id}, #{as_user_id&&Card[as_user_id].id} #{Card::WagbotID}")
      return false unless usr_id = as_user_id
      return true if usr_id == Card::WagbotID #cannot disable

      always = Card.cache.read('ALWAYS') || {}
      #warn(Rails.logger.warn "always_ok? #{usr_id}")
      if always[usr_id].nil?
        always = always.dup if always.frozen?
        always[usr_id] = !!Card[usr_id].all_roles.detect{|r|r==Card::AdminID}
        #warn(Rails.logger.warn "update always hash #{always[usr_id]}, #{always.inspect}")
        Card.cache.write 'ALWAYS', always
      end
      #warn Rails.logger.warn("aok? #{usr_id}, #{always[usr_id]}")
      always[usr_id]
    end
    # PERMISSIONS

  protected
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr_id = Card.as_user_id
      ok_hash = Card.cache.read('OK') || {}
      #warn(Rails.logger.warn "ok_hash #{usr_id}")
      if ok_hash[usr_id].nil?
        ok_hash = ok_hash.dup if ok_hash.frozen?
        ok_hash[usr_id] = begin
            Card[usr_id].all_roles.inject({:role_ids => {}}) do |ok,role_id|
              ok[:role_ids][role_id] = true
              Role[role_id].task_list.each { |t| ok[t] = 1 }
              ok
            end
          end || false
        #warn(Rails.logger.warn "update ok_hash(#{usr_id}) #{ok_hash.inspect}")
        Card.cache.write 'OK', ok_hash
      end
      r=ok_hash[usr_id]
      #warn "ok_h #{r}, #{usr_id}, #{ok_hash.inspect}";
    end

  public

    def create_these( *args )
      definitions = args.size > 1 ? args : (args.first.inject([]) {|a,p| a.push({p.first=>p.last}); a })
      definitions.map do |input|
        input.map do |key, content|
          type, name = (key =~ /\:/ ? key.split(':') : ['Basic',key])
          Card.create! :name=>name, :type=>type, :content=>content
        end
      end.flatten
    end

    NON_CREATEABLE_TYPES = %w{ invitation_request setting set }

    def createable_types
      type_names = Card.as(Card::WagbotID) do
        Card.search :type=>Card::CardtypeID, :return=>:name
      end
      noncreateable_names = NON_CREATEABLE_TYPES.map do |code|
        Card::Codename.cardname code
      end
      type_names.reject do |name|
        noncreateable_names.member?(name) || !new( :type=>name ).ok?( :create )
      end
    end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # TYPE (Class methods)

    def type_id_from_name(name)
      c=Card.fetch(name, :skip_virtual=>true, :skip_modules=>true) and c.id
    end

    def typecode_from_name(name)
      raise "zero type_id" if (tid = type_id_from_name name) == 0
      return nil if tid.nil?
      r=
      Codename.codename(tid)
      Rails.logger.warn "name2code #{tid}, #{name} #{r}"; r
    end
    
    def type_id_from_code(code)
      r=
      Card::Codename[code] || (c=Card[code] and c.id)
      Rails.logger.warn "code2tid #{r} #{code}"; r
    end
  end

#~~~~~~~ Instance

  def among? authzed
    #warn (Rails.logger.warn "among? #{name}, #{authzed.inspect} #{caller[0..4]*"\n"}") if authzed.empty?
    prties = parties
    #warn(Rails.logger.info "among called.  user = #{name}, parties = #{prties.inspect}, authzed = #{Card::AnyoneID.inspect}")
    authzed.each { |auth| return true if prties.member? auth }
    authzed.member? Card::AnyoneID
  end

  def parties
    @parties ||=  (all_roles << self.id).flatten.reject(&:blank?)
  end

  def read_rules
    return [] if id==Card::WagbotID  # avoids infinite loop
    party_keys = ['in', Card::AnyoneID] + parties
    Card.as Card::WagbotID do
      Card.search(:right=>'*read', :refer_to=>{:id=>party_keys}, :return=>:id).map &:to_i
    end
  end

  def all_roles
    ids = Card.as Card::WagbotID do
      r=(cr=trait_card(:roles)).item_cards(:limit=>0).map(&:id)
      #warn "all_roles #{inspect}: #{cr.inspect}, #{r.inspect} #{caller[0..10]*"\n"}"; r
    end
    #warn "ids string #{ids.inspect} " unless Array === ids
    @all_roles ||= (id==Card::AnonID ? [] : [Card::AuthID] + ids)
      #[Card::AuthID] + trait_card(:roles).item_cards.map(&:id))
  end

  def trait_card? tagcode
    Card.fetch cardname.trait_name(tagcode), :skip_modules=>true
  end

  def trait_card tagcode
    Card.fetch_or_new cardname.trait_name(tagcode)
  end

  def get_type_id(args={})
    #warn("get_type_id(#{args.inspect})")
    return if args[:type_id]

    type_id = case
      when args[:typecode] ;  Card.type_id_from_code args[:typecode]
      when args[:type]     ;  Card.type_id_from_name args[:type]
      else :noop
      end
    
    #warn "get_type_id after case 1"
    #warn "get_type_id[#{type_id.inspect}](#{args.inspect}) bk:#{broken_type}"
    case type_id
    when :noop      ; 
    when false, nil ; @broken_type = args[:type] || args[:typecode]
    else            ; return type_id
    end
    
    #warn "get_type_id after case 2"
    
    if name && t=template
      reset_patterns
      t.type_id
    else
      #FIXME - hardcoded id.  yuck.  
      # if we get here we have no *all+*default -- let's address that!
      ?3 #Card::DefaultTypeID  
    end
  end

  

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # SAVING

  def update_attributes(args={})
    if newtype = args.delete(:type) || args.delete('type')
      args[:type_id] = Card.type_id_from_name( newtype )
    end
    super args
  end

  def set_stamper()
    #warn "set stamper[#{name}] #{Card.user_id}, #{Card.as_user_id}" #{caller*"\n"}"
    #Card.stamper = #Card.user_id
    self.updater_id = Card.user_id
    self.creator_id = self.updater_id if new_card?
    #warn "set stamper[#{name}] #{self.creator_id}, #{self.updater_id}, #{Card.user_id}, #{Card.as_user_id}" #{caller*"\n"}"
  end
  def reset_stamper() end #Card.reset_stamper end

  def base_before_save
    if self.respond_to?(:before_save) and self.before_save == false
      errors.add(:save, "could not prepare card for destruction")
      return false
    end
  end

  def base_after_save
    save_subcards
    self.virtual = false
    @from_trash = false
    Wagn::Hook.call :after_create, self if @was_new_card
    send_notifications
    true
  rescue Exception=>e
    @subcards.each{ |card| card.expire_pieces }
    Rails.logger.info "after save issue: #{e.message}"
    raise e
  end

  def save_subcards
    @subcards = []
    return unless cards
    cards.each_pair do |sub_name, opts|
      opts[:nested_edit] = self
      sub_name = sub_name.gsub('~plus~','+')
      absolute_name = cardname.to_absolute_name(sub_name)
      if card = Card[absolute_name]
        card = card.refresh if card.frozen?
        card.update_attributes opts
      elsif opts[:content].present? and opts[:content].strip.present?
        opts[:name] = absolute_name
        card = Card.create opts
      end
      @subcards << card if card
      if card and card.errors.any?
        card.errors.each do |field, err|
          self.errors.add card.name, err
        end
        raise ActiveRecord::Rollback
      end
    end
  end

  def save_with_trash!
    save || raise(errors.full_messages.join('. '))
  end
  alias_method_chain :save!, :trash

  def save_with_trash(*args)#(perform_checking=true)
    pull_from_trash if new_record?
    self.trash = !!trash
    save_without_trash(*args)#(perform_checking)
  rescue Exception => e
    Rails.logger.warn "exception #{e} #{caller[0..1]*', '}"
    raise e
  end
  alias_method_chain :save, :trash

  def save_with_permissions(*args)  #checking is needed for update_attribute, evidently.  not sure I like it...
    #warn (Rails.logger.debug "Card#save_with_permissions![#{inspect}]")
    run_checked_save :save_without_permissions
  end
  alias_method_chain :save, :permissions

  def save_with_permissions!(*args)
    Rails.logger.debug "Card#save_with_permissions!"
    run_checked_save :save_without_permissions!
  end
  alias_method_chain :save!, :permissions

  def run_checked_save(method)#, *args)
    if approved?
      begin
        #warn "run_checked_save #{method}, tc:#{typecode.inspect}, #{type_id.inspect}"
        self.send(method)
      rescue Exception => e
        rescue_save(e, method)
      end
    else
      raise PermissionDenied.new(self)
    end
  end

  def rescue_save(e, method)
    expire_pieces
    #warn "Model exception #{method}:#{e.message} #{name}"
    Rails.logger.info "Model exception #{method}:#{e.message} #{name}"
    Rails.logger.debug "BT [[[\n#{ e.backtrace*"\n"} \n]]]"
    raise Wagn::Oops, "error saving #{self.name}: #{e.message}, #{e.backtrace*"\n"}"
  end

  def expire_pieces
    cardname.piece_names.each do |piece|
      #warn "clearing for #{piece.inspect}"
      Card.clear_cache piece
    end
  end

  def pull_from_trash
    return unless key
    return unless trashed_card = Card.find_by_key_and_trash(key, true)
    #could optimize to use fetch if we add :include_trashed_cards or something.
    #likely low ROI, but would be nice to have interface to retrieve cards from trash...
    self.id = trashed_card.id
    @from_trash = self.confirm_rename = @trash_changed = true
    @new_record = false
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # DESTROY

  def destroy_with_trash(caller="")
    run_callbacks( :destroy ) do
      deps = self.dependents
      @trash_changed = true

      self.update_attribute(:trash, true)
      deps.each do |dep|
        next if dep.trash #shouldn't be getting trashed cards
        dep.confirm_destroy = true
        dep.destroy_with_trash("#{caller} -> #{name}")
      end
      true
    end
  end
  alias_method_chain :destroy, :trash

  def destroy_with_validation
    errors.clear
    validate_destroy

    if !dependents.empty? && !confirm_destroy
      errors.add(:confirmation_required, "because #{name} has #{dependents.size} dependents")
    end

    dependents.each do |dep|
      dep.send :validate_destroy
      if !dep.errors[:destroy].empty?
        errors.add(:destroy, "can't destroy dependent card #{dep.name}: #{dep.errors[:destroy]}")
      end
    end

    errors.empty? ? destroy_without_validation : false
  end
  alias_method_chain :destroy, :validation

  def destroy!
    # FIXME: do we want to overide confirmation by setting confirm_destroy=true here?
    # This is aliased in Permissions, which could be related to the above comment
    self.confirm_destroy = true
    destroy or raise Wagn::Oops, "Destroy failed: #{errors.full_messages.join(',')}"
  end

  def base_before_destroy
    self.before_destroy if respond_to? :before_destroy
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # NAME / RELATED NAMES


  # FIXME: use delegations and include all cardname functions
  def simple?()     cardname.simple?       end
  def junction?()   cardname.junction?     end
  def key()         cardname.key           end
  def css_name()    cardname.css_name      end

  def left()      Card[cardname.left_name]  end
  def right()     Card[cardname.tag_name]   end
  def pieces()  simple? ? [self] : ([self] + trunk.pieces + tag.pieces).uniq end
  def particles() cardname.particle_names.map {|part| Card.fetch(part) }     end
  def key()       cardname.key                                               end

  def junctions(args={})
    return [] if new_record? #because lookup is done by id, and the new_records don't have ids yet.  so no point.
    args[:conditions] = ["trash=?", false] unless args.has_key?(:conditions)
    args[:order] = 'id' unless args.has_key?(:order)
    # aparently find f***s up your args. if you don't clone them, the next find is busted.
    left_junctions.find(:all, args.clone) + right_junctions.find(:all, args.clone)
  end

  def dependents(*args)
    # all plus cards, plusses of plus cards, etc
    jcts = junctions(*args)
    jcts.delete(self) if jcts.include?(self)
    return [] if new_record? #because lookup is done by id, and the new_records don't have ids yet.  so no point.
    jcts.map { |r| [r ] + r.dependents(*args) }.flatten
  end

  def repair_key
    Card.as  Card::WagbotID do
      correct_key = cardname.to_key
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

  def type_card() c=Card[type_id.to_i] end
  def typecode() Codename.codename( type_id ) end # Should we not fallback to key?
  def typename()
    return if type_id.nil?
    c=Card.fetch(type_id, :skip_modules=>true, :skip_virtual=>true) and c.name
  end

  def type=(typename) self.type_id = Card.type_id_from_name(typename)        end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # CONTENT / REVISIONS

  def content() new_card? ? template(true).content : cached_revision.content end
  def raw_content()     templated_content || content                         end
  def selected_rev_id() @selected_rev_id || (cr=cached_revision)&&cr.id || 0 end

  def cached_revision
    #return current_revision || Card::Revision.new
    if @cached_revision and @cached_revision.id==current_revision_id
    elsif ( Card::Revision.cache &&
       @cached_revision=Card::Revision.cache.read("#{cardname.css_name}-content") and
       @cached_revision.id==current_revision_id )
    else
      rev = current_revision_id ? Card::Revision.find(current_revision_id) :
                    Card::Revision.new(:creator_id => Card.user_id)
      @cached_revision = Card::Revision.cache ?
        Card::Revision.cache.write("#{cardname.css_name}-content", rev) : rev
    end
    @cached_revision
  end

  def previous_revision(revision)
    rev_index = revisions.each_with_index do |rev, index|
      rev.id == revision.id ? (break index) : nil
    end
    (rev_index.to_i==0) ? nil : revisions[rev_index - 1]
  end

  def revised_at
    (cached_revision && cached_revision.created_at) || Time.now
  end

  def author
    c=Card[creator_id]
    #warn "c author #{creator_id}, #{c}, #{self}"; c
  end

  def updater
    #warn "updater #{updater_id}, #{updater_id}"
    c=Card[updater_id|| Card::AnonID]
    #warn "c upd #{updater_id}, #{c}, #{self}"; c
  end

  def drafts
    revisions.find(:all, :conditions=>["id > ?", current_revision_id])
  end

  def save_draft( content )
    clear_drafts
    revisions.create(:content=>content, :creator_id=>Card.user_id)
  end

  protected
  def clear_drafts
    connection.execute(%{delete from card_revisions where card_id=#{id} and id > #{current_revision_id} })
  end

  public


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # METHODS FOR OVERRIDE

  def post_render( content )     content  end
  def clean_html?()                 true  end
  def collection?()                false  end
  def on_type_change()                    end
  def validate_type_change()        true  end
  def validate_content( content )         end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # MISCELLANEOUS

  def to_s()  "#<#{self.class.name}[#{type_id==0 ? 'zero': typename}:#{type_id}]#{self.attributes['name']}>" end
  def inspect()  "#<#{self.class.name}##{self.id}[#{type_id==0 ? 'zero': typename}:#{type_id}]!#{self.name}!{n:#{new_card?}:v:#{virtual}:I:#{@set_mods_loaded}:O##{object_id}:rv#{current_revision_id}} U:#{updater_id} C:#{creator_id}>" end
  def mocha_inspect()     to_s                                   end

#  def trash
    # needs special handling because default rails cache lookup uses `@attributes_cache['trash'] ||=`, which fails on "false" every time
#    ac= @attributes_cache
#    ac['trash'].nil? ? (ac['trash'] = read_attribute('trash')) : ac['trash']
#  end





  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # INCLUDED MODULES

  include Wagn::Model


  # Because of the way it chains methods, 'tracks' needs to come after
  # all the basic method definitions, and validations have to come after
  # that because they depend on some of the tracking methods.
  tracks :name, :type_id, :content, :comment

  # this method piggybacks on the name tracking method and
  # must therefore be defined after the #tracks call


  def cardname() @cardname ||= name_without_cardname.to_cardname end

  alias cardname= name=
  def name_with_cardname=(newname)
    newname = newname.to_s
    if name != newname
      @cardname = nil
      updates.add :name, newname
      reset_patterns
    end
    newname
  end
  alias_method_chain :name=, :cardname
  def cardname() @cardname ||= name.to_cardname end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # VALIDATIONS

  def validate_destroy
    # FIXME: need to make all codenamed card indestructable
    if self.id ==  Card::WagbotID or self.id ==  Card::AnonID
      errors.add :destroy, "#{name}'s is a system card.<br>  Deleting this card would mess up our revision records."
      return false
    elsif type_id== Card::UserID and Card::Revision.find_by_creator_id( self.id )
      errors.add :destroy, "Edits have been made with #{name}'s user account.<br>  Deleting this card would mess up our revision records."
      return false
    end
    #should collect errors from dependent destroys here.
    true
  end

  protected

  validate do |rec|
    return true if @nested_edit
    return true unless Wagn::Conf[:recaptcha_on] && Card.toggle( rec.rule(:captcha) )
    c = Wagn::Conf[:controller]
    return true if (c.recaptcha_count += 1) > 1
    c.verify_recaptcha( :model=>rec ) || rec.error_status = 449
  end

  validates_each :name do |rec, attr, value|
    if rec.new_card? && value.blank?
      if autoname_card = rec.rule_card(:autoname)
        Card.as  Card::WagbotID do
          autoname_card = autoname_card.refresh if autoname_card.frozen?
          value = rec.name = Card.autoname(autoname_card.content)
          autoname_card.content = value  #fixme, should give placeholder on new, do next and save on create
          autoname_card.save!
        end
      end
    end

    cdname = value.to_cardname
    if cdname.blank?
      rec.errors.add :name, "can't be blank"
    elsif rec.updates.for?(:name)
      #Rails.logger.debug "valid name #{rec.name.inspect} New #{value.inspect}"

      unless cdname.valid?
        rec.errors.add :name,
          "may not contain any of the following characters: #{
          Wagn::Cardname::CARDNAME_BANNED_CHARACTERS}"
      end
      # this is to protect against using a junction card as a tag-- although it is technically possible now.
      if (cdname.junction? and rec.simple? and rec.left_junctions.size>0)
        rec.errors.add :name, "#{value} in use as a tag"
      end

      # validate uniqueness of name
      condition_sql = "cards.key = ? and trash=?"
      condition_params = [ cdname.to_key, false ]
      unless rec.new_record?
        condition_sql << " AND cards.id <> ?"
        condition_params << rec.id
      end
      if c = Card.find(:first, :conditions=>[condition_sql, *condition_params])
        rec.errors.add :name, "must be unique-- A card named '#{c.name}' already exists"
      end

      # require confirmation for renaming multiple cards
      if !rec.confirm_rename
        pass = true
        if !rec.dependents.empty?
          pass = false
          rec.errors.add :confirmation_required, "#{rec.name} has #{rec.dependents.size} dependents"
        end

        if rec.update_referencers.nil? and !rec.extended_referencers.empty?
          pass = false
          rec.errors.add :confirmation_required, "#{rec.name} has #{rec.extended_referencers.size} referencers"
        end

        if !pass
          rec.error_view = :edit
          rec.error_status = 200 #I like 401 better, but would need special processing
        end
      end
    end
  end

  validates_each :content do |rec, attr, value|
    if rec.new_card? && !rec.updates.for?(:content)
      value = rec.content = rec.content #this is not really a validation.  is the double rec.content meaningful?  tracked attributes issue?
    end

    if rec.updates.for? :content
      rec.send :validate_content, value
    end
  end

  validates_each :current_revision_id do |rec, attrib, value|
    if !rec.new_card? && rec.current_revision_id_changed? && value.to_i != rec.current_revision_id_was.to_i
      rec.current_revision_id = rec.current_revision_id_was
      rec.errors.add :conflict, "changes not based on latest revision"
      rec.error_view = :conflict
      rec.error_status = 409
    end
  end

  validates_each :type_id do |rec, attr, value|
    # validate on update
    #warn "validate type #{rec.inspect}, #{attr}, #{value}"
    if rec.updates.for?(:type_id) and !rec.new_card?
      if !rec.validate_type_change
        rec.errors.add :type, "of #{ rec.name } can't be changed; errors changing from #{ rec.typename }"
      end
      if c = Card.new(:name=>'*validation dummy', :type_id=>value, :content=>'') and !c.valid?
        rec.errors.add :type, "of #{ rec.name } can't be changed; errors creating new #{ value }: #{ c.errors.full_messages * ', ' }"
      end
    end

    # validate on update and create
    if rec.updates.for?(:type_id) or rec.new_record?
      # invalid type recorded on create
      if rec.broken_type
        rec.errors.add :type, "won't work.  There's no cardtype named '#{rec.broken_type}'"
      end
      # invalid to change type when type is hard_templated
      if (rt = rec.right_template and rt.hard_template? and
        value != Card.type_id_from_name(rt.typename) and !rec.allow_type_change)
        rec.errors.add :type, "can't be changed because #{rec.name} is hard tag templated to #{rt.typename}"
      end
    end
  end

  validates_each :key do |rec, attr, value|
    if value.empty?
      rec.errors.add :key, "cannot be blank"
    elsif value != rec.cardname.to_key
      rec.errors.add :key, "wrong key '#{value}' for name #{rec.name}"
    end
  end

  class << self
    def setting name
      Card.as Card::WagbotID  do
        card=Card[name] and !card.content.strip.empty? and card.content
      end
    end

    def path_setting name
      name ||= '/'
      return name if name =~ /^(http|mailto)/
      Wagn::Conf[:root_path] + name
    end

    def toggle(val) val == '1' end
  end


  # these old_modules should be refactored out
  require_dependency 'flexmail.rb'
  require_dependency 'google_maps_addon.rb'
  require_dependency 'notification.rb'
end

