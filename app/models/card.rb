class Card < ActiveRecord::Base
  def destroy!
    # FIXME: do we want to overide confirmation by setting confirm_destroy=true here?
    # This is aliased in Permissions, which could be related to the above comment
    self.confirm_destroy = true
    destroy or raise Wagn::Oops, "Destroy failed: #{errors.full_messages.join(',')}"
  end
  include Wagn::Model

  #
  # == Associations
  #  
  # Given cards A, B and A+B     
  # 
  # trunk::  from the point of f of A+B,  A is the trunk  
  # tag::  from the point of view of A+B,  B is the tag
  # left_junctions:: from the point of view of B, A+B is a left_junction (the A+ part is on the left)  
  # right_junctions:: from the point of view of A, A+B is a right_junction (the +B part is on the right)  
  #
  set_table_name 'cards'
                                         
  # FIXME:  this is ugly, but also useful sometimes... do in a more thoughtful way maybe?
  cattr_accessor :debug, :cache
  Card.debug = false

   
  belongs_to :trunk, :class_name=>'Card', :foreign_key=>'trunk_id' #, :dependent=>:dependent
  has_many   :right_junctions, :class_name=>'Card', :foreign_key=>'trunk_id'#, :dependent=>:destroy  

  belongs_to :tag, :class_name=>'Card', :foreign_key=>'tag_id' #, :dependent=>:destroy
  has_many   :left_junctions, :class_name=>'Card', :foreign_key=>'tag_id'  #, :dependent=>:destroy
    
  belongs_to :current_revision, :class_name => 'Revision', :foreign_key=>'current_revision_id'
  has_many   :revisions, :order => 'id', :foreign_key=>'card_id'

  belongs_to :extension, :polymorphic=>true

#  belongs_to :updater, :class_name=>'::User', :foreign_key=>'updated_by'

  has_many :permissions, :foreign_key=>'card_id' #, :dependent=>:delete_all

  before_destroy :destroy_extension
               
    
  attr_accessor :comment, :comment_author, :confirm_rename, :confirm_destroy,
    :from_trash, :update_referencers, :allow_typecode_change, :virtual,
    :broken_type, :loaded_trunk, :blank_revision, 
    :attachment_id #should build flexible handling for this kind of set-specific attr

  cache_attributes('name', 'typecode', 'trash')
  
  def updater
    User[updated_by]
  end
    
  # apparently callbacks defined this way are called last.
  # that's what we want for this one.  
  def after_save 
    if self.typecode == 'Cardtype'
      Rails.logger.debug "Cardtype after_save resetting"
      ::Cardtype.reset_cache
    end
#      Rails.logger.debug "Card#after_save end"
    update_attachment
    true
  end
      
  def update_attachment # the module definition overrides this for card_attachements
  end

  private
#    belongs_to :reader, :polymorphic=>true  
    
    def log(msg)
      ActiveRecord::Base.logger.info(msg)
    end
    
    def on_type_change
    end  
    
  public
      
  
  def set_defaults args
    #warn "Card(#{name})#set_defaults"
    # autoname
    if args["name"].blank? and autoname_card = setting_card('autoname')
      User.as(:wagbot) do
        self.name = autoname_card.content
        autoname_card.content = autoname_card.content.next  #fixme, should give placeholder on new, do next and save on create
        autoname_card.save!
      end
    end

    #default content
    if (self.content.nil? || self.content.blank?)
      self.content = setting('content', 'default')
    end

    self.key = name.to_key if name
    self.trash=false
  end
    
  # Creation & Destruction --------------------------------------------------
  #alias_method :ar_new, :new

  

  def initialize(args={})
    #warn "initializing with args: #{args.inspect}"
    args ||= {}
    args = args.stringify_keys # evidently different from args.stringify_keys!
    args.delete 'id' # replaces slow handling of protected fields
    typename, skip_defaults = ['type', 'skip_defaults'].map{|k| args.delete k }

    @attributes = get_attributes   
    @attributes_cache = {}
    @new_record = true
    self.send :attributes=, args, false
    self.typecode = get_typecode(args['name'], typename) unless args['typecode']

    include_set_modules unless missing?
    set_defaults( args ) unless skip_defaults
    callback(:after_initialize) if respond_to_without_attributes?(:after_initialize)
    self
  end
  
  def get_typecode(name, typename)
    begin ; return Cardtype.classname_for(typename) if typename
    rescue; self.broken_type = typename
    end
    (name && tmpl=self.template) ? tmpl.typecode : 'Basic'
  end


  def get_attributes
    #was getting this from column defs.  very slow.
    @attributes ||= {"name"=>"", "key"=>"", "codename"=>nil, "typecode"=>nil, "current_revision_id"=>nil,
      "trunk_id"=>nil,  "tag_id"=>nil, "indexed_content"=>nil,"indexed_name"=>nil, "references_expired"=>nil,
      "read_rule_class"=>nil, "read_rule_id"=>nil, "extension_type"=>nil,"extension_id"=>nil,
      "created_at"=>nil, "created_by"=>nil, "updated_at"=>nil,"updated_by"=>nil, "trash"=>nil
    }
  end

    

  def after_fetch
    include_set_modules
  end
  
  def include_set_modules
    singleton_class.include_type_module(typecode)  
  end
  
=begin
  def include_singleton_modules
#    warn "include singleton mod for #{name}"
    singleton_class.include_type_module(typecode)
    #after_include if respond_to? :after_include
  end
=end

  class << self
    def include_type_module(typecode)
      #Rails.logger.info "include set #{typecode} called  #{Kernel.caller[0..4]*"\n"}"
      return unless typecode
      raise "Bad typecode #{typecode}" if typecode.to_s =~ /\W/
      suppress(NameError) { include eval "Wagn::Set::Type::#{typecode}" }
    end
    

    def find_or_create!(args={})
      find_or_create(args) || raise(ActiveRecord::RecordNotSaved)
    end
    
    def find_or_create(args={})
      raise "find or create must have name" unless args[:name]
      Card.fetch_or_create(args[:name], {}, args)
    end
    
    def find_or_new(args={})
      raise "find_or_new must have name" unless args[:name]
      Card.fetch_or_new(args[:name], {}, args)
    end
                        
  end

  def save_with_trash!
    save || raise(errors.full_messages.join('. '))
  end
  alias_method_chain :save!, :trash

  def save_with_trash(perform_checking=true)
    pull_from_trash if new_record?
    save_without_trash(perform_checking)
  end
  alias_method_chain :save, :trash   

  def reset_cardtype_cache() end

  def pull_from_trash
    return unless key
    return unless trashed_card = Card.find_by_key_and_trash(key, true) 
    #could optimize to use fetch if we add :include_trashed_cards or something.  
    #likely low ROI, but would be nice to have interface to retrieve cards from trash...
    self.id = trashed_card.id
    self.from_trash = self.confirm_rename = true
    @new_record = false
    self.before_validation_on_create
  end
  

  def multi_create(cards)
    Wagn::Hook.call :before_multi_create, self, cards
    multi_save(cards)
    Rails.logger.info "Card#callback after_multi_create"
    Wagn::Hook.call :after_multi_create, self
  end
  
  def multi_update(cards)
    Wagn::Hook.call :before_multi_update, self, cards
    multi_save(cards)
    Rails.logger.info "Card#callback after_multi_update"
    Wagn::Hook.call :after_multi_update, self
  end
  
  def multi_save(cards)
    Wagn::Hook.call :before_multi_save, self, cards
    cards.each_pair do |name, opts|
      opts[:content] ||= ""
      name = name.post_cgi.to_absolute(self.name)
      #logger.info "multi update working on #{name}: #{opts.inspect}"
      if card = Card.fetch(name, :skip_virtual=>true)
        card.update_attributes(opts)
      elsif opts[:content].present? and opts[:content].strip.present?
        opts[:name] = name
        card = Card.create(opts)
      end
      if card and !card.errors.empty?
        card.errors.each do |field, err|
          self.errors.add card.name, err
        end
      end
    end  
    Rails.logger.info "Card#callback after_multi_save"
    Wagn::Hook.call :after_multi_save, self, cards
  end

  def new_card?
    new_record? || from_trash
  end

  def destroy_with_trash(caller="")     
    if callback(:before_destroy) == false
      errors.add(:destroy, "could not prepare card for destruction")
      return false 
    end  
    deps = self.dependents
    self.update_attribute(:trash, true) 
    deps.each do |dep|
      next if dep.trash
      dep.confirm_destroy = true
      dep.destroy_with_trash("#{caller} -> #{name}")
    end

    callback(:after_destroy) 
    true
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
      if dep.errors.on(:destroy)  
        errors.add(:destroy, "can't destroy dependent card #{dep.name}: #{dep.errors.on(:destroy)}")
      end
    end

    if errors.empty?
      destroy_without_validation
    else
      return false
    end
  end
  alias_method_chain :destroy, :validation
  

   
  # Extended associations ----------------------------------------


  def left
    Card.fetch name.trunk_name, :skip_virtual=> true, :skip_after_fetch=>true
  end
  def right
    Card.fetch name.tag_name,   :skip_virtual=> true
  end
  
  def cardtype_name()
    #raise "No type: #{self.inspect}" unless self.typecode
    typecode or return 'Basic'
    ::Cardtype.name_for( typecode )
  end
  
  
  def pieces
    simple? ? [self] : ([self] + trunk.pieces + tag.pieces).uniq 
  end
  
  def particles
    name.particle_names.map{|name| Card[name]} ##FIXME -- inefficient (though scarcely used...)    
  end

  def junctions(args={})
    return [] if new_record? #because lookup is done by id, and the new_records don't have ids yet.  so no point.  
    args[:conditions] = ["trash=?", false] unless args.has_key?(:conditions)
    args[:order] = 'id' unless args.has_key?(:order)    
    # aparently find f***s up your args. if you don't clone them, the next find is busted.
    left_junctions.find(:all, args.clone) + right_junctions.find(:all, args.clone)
  end

  def dependents(*args) 
    return [] if new_record? #because lookup is done by id, and the new_records don't have ids yet.  so no point. 
    junctions(*args).map { |r| [r ] + r.dependents(*args) }.flatten 
  end

  def extended_referencers
    (dependents + [self]).plot(:referencers).flatten.uniq
  end

  def card  ## is this still necessary or just legacy from CachedCards?
    self
  end
  
  def type_card
    ct = ::Cardtype.find_by_class_name( self.typecode )
    raise("Error in #{self.name}: No cardtype for #{self.typecode}")  unless ct
    ct.card
  end

  def drafts
    revisions.find(:all, :conditions=>["id > ?", current_revision_id])
  end
         
  def save_draft( content )
    clear_drafts
    revisions.create(:content=>content)
  end

  def previous_revision(revision)
    revision_index = revisions.each_with_index do |rev, index| 
      if rev.id == revision.id 
        break index 
      else
        nil
      end
    end
    if revision_index.nil? or revision_index == 0
      nil
    else
      revisions[revision_index - 1]
    end
  end
   
  def revised_at
    if cached_revision && rtime = cached_revision.updated_at
      rtime
    else
      Time.now
    end
  end

  # Dynamic Attributes ------------------------------------------------------        
  def skip_defaults?
    # when Calling Card.new don't set defaults.  this is for performance reasons when loading
    # missing cards. 
    !!skip_defaults  ##ok.  but this line is bizarre.
  end

  def known?(   )   !(new_card? && !virtual?)  end
  def virtual?( )   @virtual                   end
  def simple?(  )   n=name and n.simple?       end
  def junction?()   n=name and n.junction?     end
  def star?(    )   n=name and n.star?         end
  
  def content   
    #ok!(:read) if !new_card?
    c = cached_revision
    c.new_record? ? "" : c.content
  end
  
  def cached_revision
    #return current_revision || get_blank_revision
    
    case
    when (@cached_revision and @cached_revision.id==current_revision_id); 
    when (@cached_revision=Card.cache.read("#{key}-content") and @cached_revision.id==current_revision_id);
    else
      @cached_revision = current_revision_id ? Revision.find(current_revision_id) : get_blank_revision
      Card.cache.write("#{key}-content", @cached_revision)
    end
    @cached_revision
  end
  
  def get_blank_revision
    @blank_revision ||= Revision.new
  end
  
  def raw_content
    templated_content || content
  end

  def codename
    return nil unless extension and extension.respond_to?(:codename)
    extension.codename
  end

  def class_name
    raise "class_name is Deprecated. use cardtype instead"
  end
  
  def name_from_parts
    simple? ? name : (trunk.name_from_parts + '+' + tag.name_from_parts)
  end
     
  def authenticated?(party)
    party==::Role[:auth]
  end

  def to_s
    "#<#{self.class.name}:#{self.attributes['name']}>"
  end

  def mocha_inspect
    to_s
  end

  def repair_key
    ::User.as :wagbot do
      correct_key = name.to_key
      current_key = key
      return self if current_key==correct_key

      saved =   ( self.key  = correct_key and self.save! )
      saved ||= ( self.name = current_key and self.save! )

      saved ? self.dependents.each { |c| c.repair_key } : self.name = "BROKEN KEY: #{name}"
      self
    end
  rescue
    self
  end


 protected
  def clear_drafts
    connection.execute(%{
      delete from revisions where card_id=#{id} and id > #{current_revision_id} 
    })
  end

  # Because of the way it chains methods, 'tracks' needs to come after
  # all the basic method definitions, and validations have to come after
  # that because they depend on some of the tracking methods.
  tracks :name, :typecode, :content, :comment

  def name_with_key_sync=(name)
    name ||= ""
    self.key = name.to_key
    self.name_without_key_sync = name
  end
  alias_method_chain :name=, :key_sync
    

  validates_presence_of :name
  validates_associated :extension #1/2 ans:  this one runs the user validations on user cards. 


  validates_each :name do |rec, attr, value|
    if rec.updates.for?(:name)
      rec.errors.add :name, "may not contain any of the following characters: #{String::CARDNAME_BANNED_CHARACTERS[1..-1].join ' '} " unless value.valid_cardname?
      # this is to protect against using a junction card as a tag-- although it is technically possible now.
      rec.errors.add :name, "#{value} in use as a tag" if (value.junction? and rec.simple? and rec.left_junctions.size>0)

      # validate uniqueness of name
      condition_sql = "cards.key = ? and trash=?"
      condition_params = [ value.to_key, false ]   
      unless rec.new_record?
        condition_sql << " AND cards.id <> ?" 
        condition_params << rec.id
      end
      if c = Card.find(:first, :conditions=>[condition_sql, *condition_params])
        rec.errors.add :name, "must be unique-- A card named '#{c.name}' already exists"
      end
      
      # require confirmation for renaming multiple cards
      if !rec.confirm_rename 
        if !rec.dependents.empty? 
          rec.errors.add :confirmation_required, "#{rec.name} has #{rec.dependents.size} dependents"
        end
      
        if rec.update_referencers.nil? and !rec.extended_referencers.empty? 
          rec.errors.add :confirmation_required, "#{rec.name} has #{rec.extended_referencers.size} referencers"
        end
      end
    end
  end

  validates_each :content do |rec, attr, value|
    if rec.updates.for?(:content)
      rec.send :validate_content, value
    end
  end
  
  validates_each :typecode do |rec, attr, value|  
    # validate on update
    if rec.updates.for?(:typecode) and !rec.new_record?
            
      if !rec.validate_type_change
        rec.errors.add :type, "of #{rec.name} can't be changed; errors changing from #{rec.cardtype_name}"        
      end
  
      if c = Card.new(:name=>'*validation dummy', :typecode=>value) and !c.valid?
        rec.errors.add :type, "of #{rec.name } can't be changed; errors creating new #{value}: #{c.errors.full_messages.join(', ')}"
      end      
    end

    # validate on update and create 
    if rec.updates.for?(:typecode) or rec.new_record?
      # invalid type recorded on create
      if rec.broken_type
        rec.errors.add :type, "won't work.  There's no cardtype named '#{rec.broken_type}'"
      end
      
      # invalid to change type when type is hard_templated
      if (rt = rec.right_template and rt.hard_template? and 
        value!=rt.typecode and !rec.allow_typecode_change)
        rec.errors.add :type, "can't be changed because #{rec.name} is hard tag templated to #{rt.cardtype_name}"
      end        
      
    end
  end  

  validates_each :key do |rec, attr, value|
    if value.empty?
      rec.errors.add :key, "cannot be blank"
    elsif value != rec.name.to_key
      rec.errors.add :key, "wrong key '#{value}' for name #{rec.name}"
    end
  end
  
  def destroy_extension
    extension.destroy if extension
    extension = nil
    true
  end
  
  def validate_content( content )
  end

  public
  def validate_type_change
    true
  end
  
  def validate_destroy    
    if extension_type=='User' and extension and Revision.find_by_created_by( extension.id )
      errors.add :destroy, "Edits have been made with #{name}'s user account.<br>  Deleting this card would mess up our revision records."
      return false
    end           
    #should collect errors from dependent destroys here.  
    true
  end
  
  def trash
    t = @attributes_cache['trash']
    t.nil? ? (@attributes_cache['trash'] = Card.columns_hash['trash'].type_cast(@attributes['trash'])) : t
  end
  
  
end  

