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

    cattr_accessor :cache  
    self.cache = {}
   
    belongs_to :trunk, :class_name=>'Card::Base', :foreign_key=>'trunk_id', :dependent=>:dependent
    has_many   :right_junctions, :class_name=>'Card::Base', :foreign_key=>'trunk_id', :dependent=>:destroy  

    belongs_to :tag, :class_name=>'Card::Base', :foreign_key=>'tag_id', :dependent=>:destroy
    has_many   :left_junctions, :class_name=>'Card::Base', :foreign_key=>'tag_id', :dependent=>:destroy
    
    belongs_to :current_revision, :class_name => 'Revision', :foreign_key=>'current_revision_id'
    has_many   :revisions, :order => 'id', :foreign_key=>'card_id'

    belongs_to :extension, :polymorphic=>true

    has_many :permissions, :foreign_key=>'card_id'#, :dependent=>:delete_all
        
    has_many :in_references, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id'
    has_many :out_references,:class_name=>'WikiReference', :foreign_key=>'card_id', :dependent=>:destroy
    
    has_many :in_transclusions, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type=?",WikiReference::TRANSCLUSION]
    has_many :out_transclusions,:class_name=>'WikiReference', :foreign_key=>'card_id',:conditions=>["link_type=?",WikiReference::TRANSCLUSION]

    has_many :in_links, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type=?",WikiReference::LINK]
    has_many :out_links,:class_name=>'WikiReference', :foreign_key=>'card_id',:conditions=>["link_type=?",WikiReference::LINK]

    has_many :referencers, :through=>:in_references
    has_many :referencees, :through=>:out_references
    
    has_many :transcluders, :through=>:in_transclusions, :source=>:referencer
    has_many :transcludees, :through=>:out_transclusions, :source=>:referencee

    has_many :linkers, :through=>:in_links, :source=>:referencer
    has_many :linkees, :through=>:out_links, :source=>:referencee
   
    before_validation_on_create :set_defaults
    after_create :update_references_on_create
    before_destroy :update_references_on_destroy
    after_save :cache_priority
     
    attr_accessor :comment, :comment_author, :confirm_rename, :confirm_destroy, 
      :change_links_on_rename, :allow_type_change
  
    private
      belongs_to :reader, :polymorphic=>true  
      
    protected    
    
    def set_defaults 
      return unless new_record?  # because create callbacks are also called in type transitions 
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
      self.priority = tag.priority if tag  # this might not be right for non-simple tags
       
      #[Permission.new(:task=>'read',:party=>::Role[:anon])] + 
      #  [:edit,:comment,:delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role[:auth])},

      { 
        :permissions => default_permissions,
        :content => defaults_template.content,
        :extension_type => template? ? 'SoftTemplate' : nil,
      }.each_pair do |attr, default|  
        unless updates.for?(attr)
          send "#{attr}=", default
        end
      end
    end
    
    def default_permissions
      perm = defaults_template.permissions.reject { |p| p.task == 'create' unless type == 'Cardtype' }
      
      perm.map do |p|  
        if p.task == 'read'
          party = p.party
          
          if trunk and tag
            trunk_reader = trunk.who_can(:read)
            tag_reader = tag.who_can(:read)
            if trunk_reader!=::Role[:anon] and tag_reader!=::Role[:anon] and trunk_reader!=tag_reader
              errors.add(:permissions, "Can't create junction between cards in different restricted read groups:" + 
                "#{trunk.name} belongs to #{trunk_reader.card.name}; " +
                "#{tag.name} belongs to #{tag_reader.card.name}"
              )
            elsif trunk_reader!=::Role[:anon]
              party = trunk_reader
            elsif tag_reader!=::Role[:anon]
              party = tag_reader
            end
          end
          Permission.new :task=>p.task, :party=>party
        else
          Permission.new :task=>p.task, :party_id=>p.party_id, :party_type=>p.party_type
        end
      end
    end
    
    def update_references_on_create    
      WikiReference.update_on_create(self)
    end
    
    def update_references_on_destroy
      WikiReference.update_on_destroy(self)
    end
    
    public
    
    # Creation & Destruction --------------------------------------------------

    class << self
      def default_class
        self==Card::Base ? Card.const_get( Card.default_cardtype_key ) : self
      end
      
      def find_or_create(args={})
        c = find_or_new(args); c.save; c
      end
      
      def find_or_new(args={})  
        args.stringify_keys!
        # FIXME -- this finds cards in or out of the trash-- we need that for
        # renaming card in the trash, but may cause other problems.
        raise "Must specify :name to find_or_create" if args['name'].blank?
        c = (c = Card::Base.find_by_key(args['name'].to_key)) ? c : get_class_from_args(args).new(args)
        c.send(:set_defaults) if c.new_record?
        c
      end                      
                                  
      # sorry, I know the next two aren't DRY, I couldn't figure out how else to do it.
      def create_with_type!(args={})
        get_class_from_args(args).create_without_type!(args)
      end
      alias_method_chain :create!, :type    

      def create_with_type(args={})
        get_class_from_args(args).create_without_type(args)
      end
      alias_method_chain :create, :type    
      
      def create_with_trash!(args={})     
        args.stringify_keys!
        if c = Card.find_by_key_and_trash(get_name_from_args(args).to_key, true)
          c.update_attributes! args.merge('trash'=>false)
          c
        else
          create_without_trash! args
        end
      end
      alias_method_chain :create!, :trash

      def create_with_trash(args={})
        args.stringify_keys!
        if c = Card.find_by_key_and_trash(get_name_from_args(args).to_key, true)
          c.update_attributes args.merge('trash'=>false)  
          c
        else
          create_without_trash args
        end
      end
      alias_method_chain :create, :trash   
      
      def get_class_from_args(args={})        
        # FIXME: this passes the test but it sure is ugly
        args ||={}  # huh?  why doesn't the method parameter do this?
        given_type = args.pull('type')
        if tag_tmpl = tag_template(get_name_from_args(args)||"")
          default_type = tag_tmpl.type
          if tag_tmpl.extension_type = 'HardTemplate'
            given_type = default_type
          end
        else 
          default_type = default_class.to_s.demodulize
        end
        given_type ||= default_type
        Card.const_get(given_type)
      end      

=begin      
      def get_class_from_args(args)
        args ||= {}
        args.stringify_keys!
        ( v     = args.pull('type')) ? Card.const_get(v) : default_class   
      end
=end
            
      def get_name_from_args(args={})
        args ||= {}
        args['name'] || (args['trunk'] && args['tag']  ? args["trunk"].name + "+" + args["tag"].name : "")
      end      
      
      
      def [](name) 
        #self.cache[name.to_s] ||= 
        
        self.find_by_name(name.to_s)
        #self.find_by_name(name.to_s)
      end
             
      # uncomment if we want to protect 'unreadable' cards from even
      # being loaded.  thinking for now let them load and check when
      # requesting content.
      #
      #def instantiate_with_permissions(record)
      #  card = instantiate_without_permissions(record)
      #  card.ok! :read
      #  card
      #end
      #alias_method_chain :instantiate, :permissions
      
    end
    
    def cache_priority
      if !simple? and tag.name == '*priority'
        value = content.to_i  #FIXME if we could trust priority to be a number could use value..
        #warn "#{name} UPDATING PRIORITY #{value} on #{trunk.name}"
        trunk.left_junctions.each do |c|
          #warn "#{name} UPDATING JUNCTION #{c.name}"
          c.update_attributes!(:priority=>value) unless c.attribute_card('*priority')
        end
        trunk.update_attribute(:priority, value)
      end
    end
        
    def destroy_with_trash(caller="")     
      if callback(:before_destroy) == false
        errors.add(:destroy, "before destroy back aborted destroy")
        return false 
      end         
      
      self.update_attribute(:trash, true) 

      self.dependents.each do |dep|
        next if dep.trash
        #puts "#{caller} -> #{name} !! #{dep.name}"
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
    def pieces
      simple? ? [self] : ([self] + trunk.pieces + tag.pieces).uniq 
    end

    def junctions(*args)
      @junctions ||= right_junctions(:order=>'id', *args) + left_junctions(:order=>id, *args)
    end

    def dependents(*args) 
      junctions(*args).map { |r| [r ] + r.dependents(*args) }.flatten 
    end

    def cardtype
      @cardtype ||= ::Cardtype.find_by_class_name( class_name ).card
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
      Card.find_by_name( name + JOINT + attr_name )
    end
     
    def revised_at
      current_revision ? current_revision.updated_at : Time.now
    end

    # Dynamic Attributes ------------------------------------------------------        
    def content
      ok!(:read) # fixme-perm.  might need this, but it's breaking create...
      if tmpl = hard_content_template and tmpl!=self
        tmpl.content
      else
        current_revision ? current_revision.content : ""
      end
    end   
    
    def type
      read_attribute :type
    end
  
    def codename
      return nil unless extension and extension.respond_to?(:codename)
      extension.codename
    end

    def class_name
      name = self.class.to_s.gsub(/^Card::/,'')
      name == 'Base' ? 'Basic' : name
    end

    def simple?() 
      self.trunk.nil? 
    end
    
    def junction?() !simple? end
       
    # FIXME: I don't really want this but it's in about 80 tests...
    def connect( other_card, content='')
      Card.create :trunk=>self, :tag=>other_card, :content=>content
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
      Card.const_get(newtype).new do |record|
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
    
    # Find / Wql --------------------------------------------------------------   
            
    class << self 
      
      def find_by_name( name ) 
        self.find_by_key_and_trash( name.to_key, false )
      end
        
      def find_by_wql_options( options={} )
        wql = Wql.generate_query( options ) 
        self.find_by_wql( wql )
#      rescue Exception=>e
#        raise Wagn::WqlError, "Error from wql options: #{options.inspect}\n#{e.message}"
      end
      
      def find_by_wql( wql, options={})
        warn "find_by_wql: #{wql} " if System.debug_wql 
        ActiveRecord::Base.logger.info("WQL #{wql}")
        statement = Wql::Parser.new.parse( wql )
        cards = self.find_by_sql statement.to_s
        statement.post_sql.each do |step|
          case step
            when 'pieces'; cards = cards.map{|c| c.pieces}.flatten
          end
        end
        cards.each do |card|
          card.cards_tagged = card.attributes['cards_tagged'] if card.attributes.has_key?('cards_tagged')
        end 
        
        cards
        #raise "#{e.inspect}"
      #rescue Exception=>e
      #  raise "WQL broke: #{wql}\n" + e.message
      rescue Exception=>e
        raise Wagn::WqlError, "Error from wql: #{wql}\n#{e.message}"
      end
      
      # FIXME Hack to keep dynamic classes from breaking after application reload in development..
      def find_with_rescue(*args)
        find_without_rescue(*args)
      rescue ActiveRecord::SubclassNotFound => e
        subclass_name = e.message.match( /subclass: '(\w+)'/ )[1]
        Card.const_get(subclass_name)
        # try one more time :-)
        find_without_rescue(*args)
      end
      alias_method_chain :find, :rescue
    end
    
       
    # Because of the way it chains methods, 'tracks' needs to come after
    # all the basic method definitions, and validations have to come after
    # that because they depend on some of the tracking methods.
    tracks :name, :content, :type, :comment, :permissions#, :reader, :writer, :appender

    validates_presence_of :name

    # FIXME what do these actually do?  is it expensive?  worth doing? 
    #  especially the polymorphic ones..
    validates_associated :trunk
    validates_associated :tag  
    validates_associated :extension
  #  validates_associated :reader
  #  validates_associated :writer 
  #  validates_associated :appender   

    validates_each :name do |rec, attr, value|
      if rec.updates.for?(:name)
        rec.errors.add :name, "may not contain #{Cardname::CARDNAME_BANNED_CHARACTERS[1..-1]} " unless value.valid_cardname?
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
          rec.errors.add :name, "a card named #{c.name} already exists"
        end
        
        # require confirmation for renaming multiple cards
        if !rec.dependents.empty? and !rec.confirm_rename
          rec.errors.add :confirmation_required, "#{rec.name} has #{rec.dependents.size} dependents"
        end    
        
        #dependents
      end
    end

    validates_each :content do |rec, attr, value|
      if rec.updates.for?(:content)
        rec.send :validate_content, value
        begin
          Renderer.instance.render_without_rescue(rec, value, update_references=false)
        rescue Exception=>e
          rec.errors.add :content, "#{e.class}: #{e.message}"
        end   
      end
    end

    # private cards can't be connected to private cards with a different group
    validates_each :permissions do |rec, attr, value|
      if rec.updates.for?(:permissions)
        rec.errors.add :permissions, 'Insufficient permissions specifications' if value.length < 3
        reader = nil
        value.each do |p|  #fixme-perm -- ugly - no alibi
          unless %w{ create read edit comment delete }.member?(p.task.to_s)
            rec.errors.add :permissions, "No such permission: #{p.task}"
          end
          if p.task == 'read' then reader = p.party end
          if p.party == nil and p.task!='comment'
            rec.errors.add :permission, "#{p.task} party can't be set to nil"
          end
        end
        (rec.dependents+(rec.junction? ? [rec.tag, rec.trunk] : [])).each do |d|   
          d_reader = d.who_can :read
          if d_reader and (d_reader!=reader) and !(d_reader.class == ::Role and d_reader.codename=='anon') 
            # and d.reader!=reader
            rec.errors.add :permissions, "group #{reader.cardname} cannot be assigned because " +
            "#{d.name} belongs to group #{d_reader.cardname}"
          end
        end       
      end
    end
    
    validates_each :type do |rec, attr, value|  
      if rec.tag_template and rec.tag_template.hard_template? and value!=rec.tag_template.type and !rec.allow_type_change
        rec.errors.add :type, "can't be changed because #{rec.name} is hard tag templated to #{rec.tag_template.type}"
      end
      if rec.updates.for?(:type)     
        rec.send :validate_destroy
        newcard = rec.send :clone_to_type, value
        newcard.valid?  # run all validations...
        rec.send :copy_errors_from, newcard
      end
    end  
    
     
    def validate_destroy  
    end
    
    def validate_content( content )
    end
    
  end
end

