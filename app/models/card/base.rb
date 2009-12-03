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
               
    before_validation_on_create :set_needed_defaults
    
    attr_accessor :comment, :comment_author, :confirm_rename, :confirm_destroy, 
      :update_referencers, :allow_type_change, :virtual, :builtin, :broken_type, :skip_defaults
        
    private
      belongs_to :reader, :polymorphic=>true  
      
      def log(msg)
        ActiveRecord::Base.logger.info(msg)
      end
      
      def on_type_change
      end  
      
    protected        
    
    # FIXME:  instead of calling c.send(:set_needed_defaults)  in a bunch of places
    #  couldn't we create initialize_with_defaults and chain it?
    def set_needed_defaults
      # new record check because create callbacks are also called in type transitions 
      return if (!new_record? || skip_defaults? || virtual? || @defaults_already_set)  
      @defaults_already_set = true
      set_defaults
      #replace_content_variables
    end
    
    def set_defaults 
      # FIXME: AccountCreationTest:test_should_require_valid_cardname
      # fails unless we add the  'and name.valid_cardname?'  below
      # but I don't understand why. it should still throw the error
      if simple? and name and name.junction? and name.valid_cardname?
        self.trunk = Card::Base.find_or_new :name=>name.parent_name
        self.tag =   Card::Base.find_or_new :name=>name.tag_name
      end
      self.name = trunk.name + JOINT + tag.name if junction?
      self.trash = false   
      self.key = name.to_key if name
      
      self.extension_type = 'SoftTemplate' if (template? and !self.extension_type)
       
      unless updates.for?(:permissions)
        self.permissions = default_permissions
      end
      
      if template.hard_template? || !updates.for?(:content) 
        self.content = ::User.as(:wagbot) { template.content }
      end

      self.name='' if self.name.nil?
    end
    
    #def replace_content_variables
      # this should search through all variables (in links and inclusions) starting with $ 
      #and replace them with either the corresponding passed-in param or ''
    #end
    
    def default_permissions
      perm = template.real_card.permissions.reject { |p| p.task == 'create' unless (type == 'Cardtype' or template?) }
      
      perm.map do |p|  
        if p.task == 'read'
          party = p.party
          
          if trunk and tag
            trunk_reader, tag_reader = trunk.who_can(:read), tag.who_can(:read)
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
    
    # Creation & Destruction --------------------------------------------------

    class << self
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
        c = Card.find(:first, :conditions=>"#{ActiveRecord::Base.connection.quote_column_name("key")} = '#{args['name'].to_key}'") || begin
          p = Proc.new {|k| k.new(args)}
          with_class_from_args(args, p)
        end
        c.send(:set_needed_defaults)

        if c.trash
          ::User.as(:wagbot) do
            c.content=''  
            c.trash=false
          end
        end
        c
      end                      
                                  
      # sorry, I know the next two aren't DRY, I couldn't figure out how else to do it.
      def create_with_type!(args={})  
        p = Proc.new {|k| k.create_without_type!(args)}
        with_class_from_args(args,p)
      end
      alias_method_chain :create!, :type    

      def create_with_type(args={})
        p = Proc.new {|k| k.create_without_type(args)}
        with_class_from_args(args,p)
      end
      alias_method_chain :create, :type    
      
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

      def class_for(given_type)
        if ::Cardtype.name_for_key?( given_type.to_key )
          given_type = ::Cardtype.classname_for( ::Cardtype.name_for_key( given_type.to_key ))
        end
        
        begin 
          Card.const_get(given_type)
        rescue Exception=>e
          nil
        end
      end
      
      def with_class_from_args(args, p)        
        args ||={}  # huh?  why doesn't the method parameter do this?

        given_type = args.pull('type')
        tag_template = right_template(get_name_from_args(args)||"")

        
        broken_type = nil
        
        requested_type = case
          when tag_template && tag_template.hard_template?;   tag_template.type  
          when given_type;                                    given_type
          when tag_template && tag_template.soft_template?;   tag_template.type
          else                                                default_class.to_s.demodulize  # depends on what class we're in
        end

        klass = Card.class_for( requested_type ) || begin
          broken_type = requested_type
          Card::Basic
        end
     
        card = p.call( klass )
        card.broken_type = broken_type
        card
      end
            
      def get_name_from_args(args={})
        args ||= {}
        args['name'] || (args['trunk'] && args['tag']  ? args["trunk"].name + "+" + args["tag"].name : "")
      end      
      
      def [](name) 
        # DONT do find_virtual here-- it ends up happening all over the place--
        # call it explicitly if that's what you want
        #self.cache[name.to_s] ||= 
        self.find_by_name(name.to_s, :include=>:current_revision) #|| self.find_virtual(name.to_s)
        #self.find_by_name(name.to_s)
      end             
    end

    def multi_create(cards)
      multi_save(cards)
    end
    
    def multi_update(cards)
      multi_save(cards)
      Notification.after_multi_update(self)  # future system hook
    end
    
    def multi_save(cards)
      Notification.before_multi_save(self,cards)  # future system hook
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
    def sets
      Wagn::Pattern.keys_for_card( self ).map do |key|
        Card.find_by_pattern_spec_key( key )
      end.compact + 
      [Card['*all']]
    end
    
    def left
      trunk
    end
    
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

    def cardtype
      @cardtype ||= ::Cardtype.find_by_class_name( self.type ).card
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
        CachedCard.get_real( name + JOINT + attr_name )
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
      if tmpl = hard_template and tmpl!=self
        tmpl.content
      else
        current_revision ? current_revision.content : ""
      end
    end   
    
    def edit_instructions #returns card
      tag_card = tag || (name and Card[name.tag_name])
      (tag_card && tag_card.attribute_card('*edit')) || 
         (cardtype and cardtype.attribute_card('*edit'))
    end
    
    def new_instructions  
      if value = self.setting('new')
        return value
      end
      [tag, cardtype].each do |tsar|
        %w{ *new *edit}.each do |attr_card|
          if tsar and instructions = tsar.attribute_card(attr_card)
            return instructions
          end
        end
      end
      return nil
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
       
    # FIXME: I don't really want this but it's in about 80 tests...
    def connect( other_card, content='')
      Card.create :trunk=>self, :tag=>other_card, :content=>content
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
