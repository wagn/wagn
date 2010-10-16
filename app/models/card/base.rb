module Card
  
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
  class Base < ActiveRecord::Base
    set_table_name 'cards'
                                         
    # FIXME:  this is ugly, but also useful sometimes... do in a more thoughtful way maybe?
    cattr_accessor :debug    
    Card::Base.debug = false

#    cattr_accessor :cache  
#    self.cache = {}

   
    [:before_validation, :before_validation_on_create, :after_validation, 
      :after_validation_on_create, :before_save, :before_create, :after_create,
      :after_save
    ].each do |callback|
      self.send(callback) do 
        Rails.logger.debug "Card#callback #{callback}"
      end
    end
   
   
    belongs_to :trunk, :class_name=>'Card::Base', :foreign_key=>'trunk_id' #, :dependent=>:dependent
    has_many   :right_junctions, :class_name=>'Card::Base', :foreign_key=>'trunk_id'#, :dependent=>:destroy  

    belongs_to :tag, :class_name=>'Card::Base', :foreign_key=>'tag_id' #, :dependent=>:destroy
    has_many   :left_junctions, :class_name=>'Card::Base', :foreign_key=>'tag_id'  #, :dependent=>:destroy
    
    belongs_to :current_revision, :class_name => 'Revision', :foreign_key=>'current_revision_id'
    has_many   :revisions, :order => 'id', :foreign_key=>'card_id'

    belongs_to :extension, :polymorphic=>true

    belongs_to :updater, :class_name=>'::User', :foreign_key=>'updated_by'

    has_many :permissions, :foreign_key=>'card_id' #, :dependent=>:delete_all

    before_destroy :destroy_extension
               
    #before_validation_on_create :set_needed_defaults
    
    attr_accessor :comment, :comment_author, :confirm_rename, :confirm_destroy, 
      :update_referencers, :allow_type_change, :virtual, :builtin, :broken_type, :skip_defaults

    # setup hooks on AR callbacks
    [:before_save, :before_create, :after_save, :after_create].each do |hookname| 
      self.send( hookname ) do |card|
        Wagn::Hook.call hookname, card
      end
    end
      
        
    # apparently callbacks defined this way are called last.
    # that's what we want for this one.  
    def after_save 
      if card.type == 'Cardtype'
        Rails.logger.debug "Cardtype after_save resetting"
        ::Cardtype.reset_cache
      end
      Rails.logger.debug "Card#after_save end"
      true
    end
        
    private
      belongs_to :reader, :polymorphic=>true  
      
      def log(msg)
        ActiveRecord::Base.logger.info(msg)
      end
      
      def on_type_change
      end  
      
    protected        
    
    def set_defaults args
      # autoname
      Rails.logger.debug "Card(#{name})#set_defaults begin"
      if args["name"].blank?
        ::User.as(:wagbot) do
          if ac = setting_card('autoname') and autoname_card = ac.card
            self.name = autoname_card.content
            autoname_card.content = autoname_card.content.next
            autoname_card.save!
          end                                         
        end
      end
      
      # auto-creation of left and right components
      # if trunk and tag are new, they will be saved when the parent
      # card is saved.
      if simple? and name and name.junction? and name.valid_cardname? 
        self.trunk = Card.find_or_new :name=>name.parent_name
        self.tag =   Card.find_or_new :name=>name.tag_name
        #puts "Found or Newed trunk #{self.trunk.name}"
        #puts "Found or Newed tag #{self.tag.name}"
        raise Exception, "missing permissions on #{self.trunk.name}" if self.trunk.permissions.empty?
        raise Exception, "missing permissions on #{self.tag.name}, #{self.tag.inspect}" if self.tag.permissions.empty?
      end
      
      # now that we have trunk and tag;
      # handle default content and permissions
      if new_record? and !virtual?
        if !args['permissions']
          self.permissions = default_permissions
        end

        ::User.as(:wagbot) do
          if !args['content'] and self.content.blank? and default_card = setting_card('default')
            self.content = default_card.content
          end
        end
      end
      
      # misc defaults- trash, key, fallbacks
      self.trash = false   
      self.key = name.to_key if name
      self.name='' if name.nil?
      Rails.logger.debug "Card(#{name})#set_defaults end"
      self
    end

    
    def default_permissions
      source_card = setting_card('content')
      if source_card
        perms = source_card.card.permissions.reject { 
          |p| p.task == 'create' unless (type == 'Cardtype' or template?) 
        }
      else
        #raise( "Missing permission configuration for #{name}" ) unless source_card && !source_card.permissions.empty?
        perms = [:read,:edit,:delete].map{|t| ::Permission.new(:task=>t.to_s, :party=>::Role[:auth])}
      end
    
      # We loop through and create copies of each permission object here because
      # direct copies end up re-assigning which card the permission objects are assigned to.
      # leads to painful errors.
      perms.map do |p|  
        if p.task == 'read'
          party = p.party
          
          if trunk and tag
            trunk_reader, tag_reader = trunk.who_can(:read), tag.who_can(:read)
            if !trunk_reader or !tag_reader
              raise "bum permissions: #{trunk.name}:#{trunk_reader}, #{tag.name}:#{tag_reader}"
            end
            if trunk_reader.anonymous? or (authenticated?(trunk_reader) and !tag_reader.anonymous?)
              party = tag_reader
            else
              party = trunk_reader
            end
          end
          Permission.new :task=>p.task, :party=>party
        else
          Permission.new :task=>p.task, :party_id=>p.party_id, :party_type=>p.party_type
        end
      end
    end
    
        
    public

    # FIXME: this is here so that we can call .card  and get card whether it's cached or "real".
    # goes away with cached_card refactor
    def card
      self
    end
    
    # Creation & Destruction --------------------------------------------------
    class << self
      alias_method :ar_new, :new

      def new(args={})
        # standardize arguments ( why strings? )
        args = {} if args.nil?
        args = args.stringify_keys

        # FIXME: if a name is given, do we want to check 
        # if the card is virtual or in the trash?

        # set the type from the class we're called from 
        calling_class = self.name.split(/::/).last
        if calling_class != 'Base'
          args['type'] = calling_class
        end

        # set type from settings
        if !args['type']
          if args.delete('skip_type_lookup')
            args['type'] = "Basic"
          else
            default_card = Card::Basic.new({
              :name=> args['name'],
              :type => "Basic",
              :skip_defaults=>true
            }).setting_card('content')
            args['type'] = default_card ? default_card.type : "Basic"
          end
        end
        
        card_class = Card.class_for( args['type'] ) || (
          broken_type = args['type']; Card::Basic
        )

        # create the new card based on the class we've determined
        args.delete('type')
        
        new_card = card_class.ar_new args
        yield(new_card) if block_given?
        new_card.broken_type = broken_type if broken_type
        new_card.send( :set_defaults, args ) unless args['skip_defaults'] 
        new_card
      end 

      def get_name_from_args(args={})
        args ||= {}
        args['name'] || (args['trunk'] && args['tag']  ? args["trunk"].name + "+" + args["tag"].name : "")
      end      

      # FIXME: I hate hate hate hate this trash code.
      def create_with_trash!(args={})   
        args.stringify_keys!
        if c = Card.find_by_key_and_trash(get_name_from_args(args).to_key, true)
          args.merge('trash'=>false).each { |k,v|  c.send( "#{k}=", v ) }
          c.send(:callback, :before_validation_on_create)
          c.save!   
          c
        else
          create_without_trash! args
        end
      end
      alias_method_chain :create!, :trash

      def create_with_trash(args={})
        args.stringify_keys!
        if c = Card.find_by_key_and_trash(get_name_from_args(args).to_key, true)
          args.merge('trash'=>false).each { |k,v|  c.send( "#{k}=", v) }
          c.send(:callback, :before_validation_on_create)
          c.save
          c
        else
          create_without_trash args
        end
      end
      alias_method_chain :create, :trash   
      
      def default_class
        self==Card::Base ? Card.const_get( Card.default_cardtype_key ) : self
      end
      
      def find_or_create!(args={})
        c = find_or_new(args); c.save!; c
      end
      
      def find_or_create(args={})
        c = find_or_new(args); c.save; c
      end
      
      def find_or_new(args={})
        args.stringify_keys!
        raise "Must specify :name to find_or_create" if args['name'].blank?
        column = ActiveRecord::Base.connection.quote_column_name("key")  # really there's not a better way to do this?
        if c = Card.find(:first, :conditions=>"#{column} = '#{args['name'].to_key}'")
          raise "missing permissions from find #{c.name}" if c.permissions.empty?
        else
          c = Card.new( args )
          raise "missing permissions from new" if c.permissions.empty?
        end

        if c.trash
          ::User.as(:wagbot) do
            c.content=''  
            c.trash=false
          end
        end
        c
      end                      
    end

    def multi_create(cards)
      Wagn::Hook.call :before_multi_create, self, cards
      multi_save(cards)
      Wagn::Hook.call :after_multi_create, self
    end
    
    def multi_update(cards)
      Wagn::Hook.call :before_multi_update, self, cards
      multi_save(cards)
      Wagn::Hook.call :after_multi_update, self
    end
    
    def multi_save(cards)
      Wagn::Hook.call :before_multi_save, self, cards
      cards.each_pair do |name, opts|              
        opts[:content] ||= ""   
        # make sure blank content doesn't override pointee assignments if they are present
        if (opts['pointee'].present? or opts['pointees'].present?) 
          opts.delete('content')
        end                                                                               
        name = name.post_cgi.to_absolute(self.name)
        logger.info "multi update working on #{name}: #{opts.inspect}"
        if card = Card[name]      
          card.update_attributes(opts)
        elsif opts[:pointee].present? or opts[:pointees].present? or  
                (opts[:content].present? and opts[:content].strip.present?)
          opts[:name] = name                
          if ::Cardtype.create_ok?( self.type ) && !::Cardtype.create_ok?( Card.new(opts).type )
            ::User.as(:wagbot) { Card.create(opts) }
          else
            Card.create(opts)
          end
        end
        if card and !card.errors.empty?
          card.errors.each do |field, err|
            self.errors.add card.name, err
          end
        end
      end  
      Wagn::Hook.call :after_multi_save, self, cards
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
        #warn "DESTROY  #{caller} -> #{name} !! #{dep.name}"
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
    
    def destroy!
      # FIXME: do we want to overide confirmation by setting confirm_destroy=true here?
      self.confirm_destroy = true
      destroy or raise Wagn::Oops, "Destroy failed: #{errors.full_messages.join(',')}"
    end
     
    # Extended associations ----------------------------------------

    def right
      tag
    end
    
    def pieces
      simple? ? [self] : ([self] + trunk.pieces + tag.pieces).uniq 
    end
    
    def particles
      name.particle_names.map{|name| Card[name]} ##FIXME -- inefficient (though scarcely used...)    
    end

    def junctions(args={})     
      args[:conditions] = ["trash=?", false] unless args.has_key?(:conditions)
      args[:order] = 'id' unless args.has_key?(:order)    
      # aparently find f***s up your args. if you don't clone them, the next find is busted.
      left_junctions.find(:all, args.clone) + right_junctions.find(:all, args.clone)
    end

    def dependents(*args) 
      junctions(*args).map { |r| [r ] + r.dependents(*args) }.flatten 
    end

    def extended_referencers
      (dependents + [self]).plot(:referencers).flatten.uniq
    end

    def card
      self
    end

    def cardtype
      @cardtype ||= begin
        ct = ::Cardtype.find_by_class_name( self.type )
        raise("Error in #{self.name}: No cardtype for #{self.type}")  unless ct
        ct.card
      end
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
    
    # I don't really like this.. 
    def attribute_card( attr_name )
      ::User.as :wagbot do
        Card.fetch( name + JOINT + attr_name , :skip_virtual => true)
      end
    end
     
    def revised_at
      current_revision ? current_revision.updated_at : Time.now
    end

    # Dynamic Attributes ------------------------------------------------------        
    def skip_defaults?
      # when Calling Card.new don't set defaults.  this is for performance reasons when loading
      # missing cards. 
      !!skip_defaults
    end

    def known?
      !(new_record? && !virtual?)
    end
    
    def virtual?
      @virtual || @builtin
    end    
    
    def builtin?
      @builtin
    end
    
    def clean_html?
      true
    end
    
    def content   
      # FIXME: we keep having permissions break when looking up system cards- this isn't great but better than error.
      #unless name=~/^\*|\+\*/  
        new_record? ? ok!(:create_me) : ok!(:read) # fixme-perm.  might need this, but it's breaking create...
      #end
      current_revision ? current_revision.content : ""
    end   
        
    def type
      read_attribute :type
    end
  
    def codename
      return nil unless extension and extension.respond_to?(:codename)
      extension.codename
    end

    def class_name
      raise "class_name is Deprecated. use type instead"
    end
    
    def name_from_parts
      simple? ? name : (trunk.name_from_parts + '+' + tag.name_from_parts)
    end

    def simple?() 
      self.trunk.nil? 
    end
    
    def junction?() !simple? end
       
    def authenticated?(party)
      party==::Role[:auth]
    end

    def to_s
      "#<#{self.class.name}:#{self.attributes['name']}>"
    end

    def mocha_inspect
      to_s
    end
     
   protected
    def clear_drafts
      connection.execute(%{
        delete from revisions where card_id=#{id} and id > #{current_revision_id} 
      })
    end

    
    def clone_to_type( newtype )
      attrs = self.attributes_before_type_cast
      attrs['type'] = newtype 
      Card.class_for(newtype).new do |record|
        record.send :instance_variable_set, '@attributes', attrs
        record.send :instance_variable_set, '@new_record', false
        # FIXME: I don't really understand why it's running the validations on the new card?
        record.allow_type_change = allow_type_change
      end
    end
    
    def copy_errors_from( card )
      card.errors.each do |attr, err|
        self.errors.add attr, err
      end
    end
       
    # Because of the way it chains methods, 'tracks' needs to come after
    # all the basic method definitions, and validations have to come after
    # that because they depend on some of the tracking methods.
    tracks :name, :content, :type, :comment, :permissions#, :reader, :writer, :appender

    def name_with_key_sync=(name)
      name ||= ""
      self.key = name.to_key
      self.name_without_key_sync = name
    end
    alias_method_chain :name=, :key_sync
      

    validates_presence_of :name

    # FIXME what do these actually do?  is it expensive?  worth doing? 
    #  especially the polymorphic ones..
    #validates_associated :trunk
    #validates_associated :tag   #-- breaks priority spec
    validates_associated :extension #1/2 ans:  this one runs the user validations on user cards. 
  #  validates_associated :reader
  #  validates_associated :writer 
  #  validates_associated :appender   
    
    
    # Freaky-- when enabled, this throws some Confirmation required errors on things that shouldn't be changing
    # in the template_spec
    #validates_each :trunk do |rec,attr,value|
    #  if card = value
    #    if !card.valid? 
    #      rec.errors.add :trunk, card.errors.full_messages.join(',')
    #    end
    #  end
    #end

    validates_each :name do |rec, attr, value|
      if rec.updates.for?(:name)
        rec.errors.add :name, "may not contain any of the following characters: #{Cardname::CARDNAME_BANNED_CHARACTERS[1..-1].join ' '} " unless value.valid_cardname?
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
        begin 
          res = Renderer.new.render(rec, value, update_references=false)
        rescue Exception=>e
          rec.errors.add :content, "#{e.class}: #{e.message}"
        end   
      end
    end

    # private cards can't be connected to private cards with a different group
    validates_each :permissions do |rec, attr, value|
      if rec.updates.for?(:permissions)
        rec.errors.add :permissions, 'Insufficient permissions specifications' if value.length < 3
        reader,err = nil, nil
        value.each do |p|  #fixme-perm -- ugly - no alibi
          unless %w{ create read edit comment delete }.member?(p.task.to_s)
            rec.errors.add :permissions, "No such permission: #{p.task}"
          end
          if p.task == 'read' then reader = p.party end
          if p.party == nil and p.task!='comment'
            rec.errors.add :permission, "#{p.task} party can't be set to nil"
          end
        end


        if err
          rec.errors.add :permissions, "can't set read permissions on #{rec.name} to #{reader.cardname} because #{err}"
        end
      end
    end
    
    
    validates_each :type do |rec, attr, value|  
      # validate on update
      if rec.updates.for?(:type) and !rec.new_record?
        
        # invalid to change type when cards of this type exists
        if rec.type == 'Cardtype' and rec.extension and ::Card.find_by_type(rec.extension.codename)
          rec.errors.add :type, "can't be changed to #{value} for #{rec.name} because #{rec.name} is a Cardtype and cards of this type still exist"
        end
    
        rec.send :validate_type_change
        newcard = rec.send :clone_to_type, value
        newcard.valid?  # run all validations...
        rec.send :copy_errors_from, newcard
      end

      # validate on update and create 
      if rec.updates.for?(:type) or rec.new_record?
        # invalid type recorded on create
        if rec.broken_type
          rec.errors.add :type, "won't work.  There's no cardtype named '#{rec.broken_type}'"
        end
        
        # invalid to change type when type is hard_templated
        if (rec.right_template and rec.right_template.hard_template? and 
          value!=rec.right_template.type and !rec.allow_type_change)
          rec.errors.add :type, "can't be changed because #{rec.name} is hard tag templated to #{rec.right_template.type}"
        end        
        
        # must be cardtype name or constant name
        unless Card.class_for(value)
          rec.errors.add :type, "won't work.  There's no cardtype named '#{value}'"
        end
      end
    end  
  
    validates_each :key do |rec, attr, value|
      unless value == rec.name.to_key
        rec.errors.add :key, "wrong key '#{value}' for name #{rec.name}"
      end
    end
     
    def validate_destroy    
      if extension_type=='User' and extension and Revision.find_by_created_by( extension.id )
        errors.add :destroy, "Edits have been made with #{name}'s user account.<br>  Deleting this card would mess up our revision records."
        return false
      end           
      #should collect errors from dependent destroys here.  
      true
    end

    def validate_type_change  
    end
    
    def destroy_extension
      extension.destroy if extension
      extension = nil
      true
    end
    
    def validate_content( content )
    end
    
  end
end
