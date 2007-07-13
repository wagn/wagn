require_dependency 'advanced_delegation'

module Card
  class Base < ActiveRecord::Base
    set_table_name 'cards'
          
    cattr_accessor :debug    
    Card::Base.debug = false
          
    
    validates_presence_of :name
    validates_uniqueness_of :name
    
   # Relationships -------------------------------------------------------------
    
    belongs_to :tag
    
    belongs_to :trunk, :class_name=>'Card::Base', :foreign_key=>'trunk_id'
    has_many   :children, :class_name=>'Card::Base', :foreign_key=>'trunk_id', :dependent=>:destroy  
    
    belongs_to :current_revision, :class_name => 'Revision', :foreign_key=>'current_revision_id'
    has_many   :revisions, :order => 'id', :foreign_key=>'card_id', :dependent=>:destroy
    
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
    
    belongs_to :created_by, :class_name=>"::User", :foreign_key=>"created_by"
    belongs_to :updated_by, :class_name=>"::User", :foreign_key=>"updated_by"
  
    belongs_to :extension, :polymorphic=>true
    
    belongs_to :role, :class_name=>'::Role', :foreign_key=>'role_id'
    
    belongs_to :reader, :polymorphic=>true
    belongs_to :writer, :polymorphic=>true
    
   # Delegations ---------------------------------------------------------------
    
    delegate_to :datatype, :content_for_rendering, :editor_type, :pre_render, :post_render, :cacheable?
    
    attr_accessor :dying
    
   # Class Properties ----------------------------------------------------------
    
    LOCKING_PERIOD = 30.minutes
    
    class_inheritable_accessor :wiki_joint
    self.wiki_joint= JOINT
    
    class_inheritable_accessor :wiki_joint_formal
    self.wiki_joint_formal=" <span class=\"wiki-joint\">#{JOINT}</span> "
    


   # Callbacks
   before_validation_on_create :setup_card
     
   def setup_card
     #warn "BEFORE CREATE: #{self.name}"

     if self.simple? and !self.tag
       t = Tag.create( :name=>self.send(:initial_name) )
       t.errors.each do |attr,msg| self.errors.add(attr,msg) end 
       #t.save! #or raise "Failed to create tag with name '#{self.send(:initial_name)}''"
       self.tag_id = t.id
     elsif self.trunk
       self.name = self.trunk.name + JOINT + self.tag.name
     end

     self.name = self.tag.name if self.tag and self.name.nil?
     self.content = "" if self.content.nil?
     self.datatype.validate( self.content )
     self.content = self.datatype.before_save( self.content )

     self.priority = 0 if self.priority.nil?

     # FIXME there should probably be a validation of some checking in the api 
     # that doesn't let this situation happen: where the id is set but not the type.
     # This is kindof a hacky one-off fix to the fact that the ids and not the types are sent from
     # the interface on create.  blech
     if (self.reader_id and !self.reader_type) then self.reader = Role.find( self.reader_id ) end
     if (self.writer_id and !self.writer_type) then self.writer = Role.find( self.writer_id ) end
   end
   

   # Object properties ---------------------------------------------------------
    
    attr_accessor :cards_tagged      
    
    def datatype_key=(value)
      raise("Can't change datatype of connection card") unless simple?
      tag.datatype_key = value
      tag.save
    end
    
    def plus_datatype_key=(value)
      raise("Can't change plus_datatype of connection card") unless simple?
      tag.plus_datatype_key = value
      tag.save
    end
    
    def rename(newname, update_references=true)  
      oldname = name                                   
      puts("\nrename #{oldname} => #{newname} ") if self.class.debug
      return if oldname==newname
      
      if simple? and !cousins.empty? and newname.include?(JOINT)
        # we can't change from a simple into a junction if we're
        # being used as a tag.  For now, just raise an error on this.
        raise Wagn::Oops, "can't rename #{name} to #{newname} because #{name} is used as a tag"
      elsif !newname.valid_cardname?
        raise Wagn::Oops, "can't rename #{name} to #{newname} because cardnames may not contain #{Cardname::CARDNAME_BANNED_CHARACTERS[1..-1]} "
      elsif c=Card.find_by_name(newname)
        raise Wagn::Oops, "can't rename #{name} to #{newname} because #{newname} already exists"
      end   
      
      if simple? and newname.simple?
        # simple to simple: no problem:
        tag.rename(newname)
        update_attribute(:name, newname)
      else       
        # move the current card out of the way, in case the new name will require
        # re-creating a card with the current name, ie.  A -> A+B
        self.trunk = nil; self.name = ''; save(false)  # skip validations
                
        puts "trunk: #{self.trunk}" if self.class.debug 

        if newname.simple?
          self.tag = Tag.create(:name=>newname)
          self.name = newname
        else
          self.trunk = Card.find_or_create(newname.parent_name)
          self.tag = Card.find_or_create(newname.tag_name).tag
          self.name = title_tag_names.join(JOINT)
        end

        save!
      end    
         
      # update the name cache all down the tree
      dependents.each do |card|
        card.update_attribute(:name, card.title_tag_names.join(JOINT))
      end

      # update references (unless we're asked not to)
      if update_references
        (dependents + [self]).plot(:linkers).flatten.uniq.each do |linker|
          WagBot.instance.revise_card_links( linker, oldname, newname )
        end
        
        # don't do update_on_destroy for old links-- those should have been repointed
        # to the new card.  but it's possible there were existing links to the new card
        WikiReference.update_on_create( self )
      end
      
      # log the change
      RecentChange.log( 'renamed', self )
      
      reload  
      self
    end
    
    
    def just_revised?
      @revised
    end
    
    def initial_name
      name
    end
    
    def name_in_context(parent)
      parent == self ? name : name.gsub(parent.name, '')
    end
    
    def content=( new_content )
      if new_record?
        @initial_content = new_content
      else
        revise( new_content )
      end
    end
    
    def content
      if cr = current_revision
        cr.content
      else
        @initial_content
      end
    end
    
    def revised_at
      updated_at
    end
    
    def codename
      return nil unless extension and extension.respond_to?(:codename)
      extension.codename
    end
    
    def class_name
      self.class.to_s.gsub(/^Card::/,'')
    end
    
    def simple?() self.trunk.nil? end
      
    def datatype_key 
      simple? ? tag.datatype_key : tag.plus_datatype_key
    end
      
    def datatype
      if @datatype.nil? or (@old_datatype_key != datatype_key)
        @old_datatype_key = datatype_key
        @datatype = Datatype[datatype_key].new(self)
      else
        @datatype
      end
    end
  
    def backlinks
      Card.find_by_wql("cards that link to cards where id=#{id}")
    end
    
    def backlinks?
      !backlinks.empty?
    end
  
    def queries
      if !@queries
        @queries = ['plus_cards', 'plussed_cards']
        @queries<< 'pieces' if !simple?
        @queries<< 'backlinks' if backlinks?
      end
      @queries
    end

    def revisions?
      revisions.size > 1
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

    def wiki_words
      references.select { |ref| ref.wiki_word? }.map { |ref| ref.referenced_name }
    end
    
    def title_tag_names
      root_cards.plot(:tag).plot(:name)
    end
  
    def title
      name
    end
    
    def formal_title
      title_tag_names.join wiki_joint_formal
    end
    
    def template?
      !simple? and tag.root_card and tag.root_card.name == '*template' 
    end 

    def templatee?
      self.template != self
    end  
    
    def plus_template?
      simple? and attribute_card('*template') 
    end
    
    def sidebar_card?
      attribute_card('*sidebar') or tag.root_card.plus_sidebar
    end
    
    def value
      # this should depend on datatype
      content.strip.split(/\s+/)[0]
    end
    
    def drafts
      revisions.find(:all, :conditions=>["id > ?", current_revision_id])
    end

   # Permissions --------------------------------------------------------------
    def permit_destroy?
      edit_ok? and System.ok?(:remove_cards) 
    end
    
    def permit_edit?
      edit_ok?
    end  
        
    def update_attributes_with_permissions(*args)       
      raise(Wagn::PermissionDenied,"edit this card") unless edit_ok?( refresh_role = true )
      update_attributes_without_permissions(*args)
    end                        
    
    def destroy_with_permissions(*args) 
      if permit_destroy?
         destroy_without_permissions(*args)
       else
         raise Wagn::PermissionDenied, "You don't have permission to destroy #{self.class_name} cards"
       end
    end
    
    def check_destroy_permission
      edit_ok! false, false #should be able to delete templated cards if otherwise permitted
      raise(Wagn::PermissionDenied,"remove this card") unless System.ok?(:remove_cards)
    end 
     
    def reader_with_permissions=( reader )
      assign_role_with_permissions( "reader", reader )
    end
    
    def writer_with_permissions=( writer )
      assign_role_with_permissions( "writer", writer )
    end                                 
    
    alias_method_chain :reader=, :permissions
    alias_method_chain :writer=, :permissions
    alias_method_chain :destroy, :permissions
    alias_method_chain :update_attributes, :permissions

    def assign_role_with_permissions( target, party )
      
      if self.send(target) == party
        #warn "ASSIGN #{target} ALREADY MATCHES #{party}"
        return                                          
      elsif party.nil?
        #warn "ASSIGN #{target} PARTY IS NIL"
        #
      elsif ::User===party
        #warn "ASSIGN #{target} #{party.cardname}"
        unless ::User.current_user == party or System.always_ok?
          raise Wagn::PermissionDenied, "set the #{target} of this card to user #{party.login}, " +
            "because you are not that user"
        end
      elsif ::Role===party                  
        #warn "ASSIGN #{target} #{party.codename}"
        unless System.role_ok?( party.id )  or System.always_ok?
          raise Wagn::PermissionDenied, "set the #{target} of this card to group #{party.cardname}, " +
            "because you are not in that group"
        end
      else
        raise "Can't assign #{target}: #{party} must be User, Role, or nil"
      end
      unless new_record?
        unless System.ok?(:manage_permissions)
          raise Wagn::PermissionDenied, "change the #{target} of this card, " +
            "because you don't have permission to manage partys"
        end
        edit_ok!
        
        dependents.each do |d|
          if d.send(target) and d.send(target)!=self.send(target) and d.send(target)!=party
            raise Wagn::PermissionDenied, "change the #{target} of this card. </br>\n" + 
              "private/locked cards can't be connected to private/locked cards with a different group" +
              "( can't assign #{self.name} to group #{party.cardname}, " +
              "because #{d.name} belongs to group #{d.send(target).card.name} )"
          end
        end
        
        dependents.each do |d| d.send("#{target}=", party) end
        dependents.each do |d| d.save end
      end
      self.send("#{target}_without_permissions=", party )
    end
    
    def private?
      !self.reader.nil?
    end
    
    def locked?
      !self.writer.nil?
    end
    
    def read_ok!
      if Card.find_by_wql("cards where id=#{self.id}").length==0
        raise Wagn::PermissionDenied, "view this card"
      end
    end
    
    def edit_ok!( refresh_role = false, check_template=true )
      if locked?
        if writer_type=='Role'
          unless System.role_ok?(writer_id)
            raise Wagn::PermissionDenied, "edit card #{self.name} " +
              "because it is locked to group #{self.writer.cardname}" +
              "and you are not a member of that group"
          end
        elsif writer_type=='User'
          unless ::User.current_user.id==writer_id
            raise Wagn::PermissionDenied, "edit card #{self.name} " +
              "because it is locked to user #{self.writer.login}"
          end
        else
          raise "How can this card be locked if it's writer type isn't Role or User ???"
        end
      else
        unless System.ok?(:edit_cards)
          raise Wagn::PermissionDenied, "edit card #{self.name} " +
            "because you don't have permission to edit cards"
        end
        if check_template and templatee?
          raise Wagn::PermissionDenied, "edit card #{self.name} " +
            "because it is a template"
        end
      end
      if datatype_key=='Server' and !System.ok?( :edit_server_cards )
        raise Wagn::PermissionDenied, "edit card #{self.name} " + 
          "because you don't have permission to edit server cards"
      end
      return true
    end
    
    def edit_ok?( refresh_role = false, check_template=true )
      edit_ok!( refresh_role, check_template )
      return true
    rescue Wagn::PermissionDenied=>e
      return false
    end

   # Methods retrieving related cards ------------------------------------------
        
    def template
      @template ||=
        case
          when template = cardtype.attribute_card('*template');  template
          when (!simple? and tag.root_card and tag.root_card.plus_template?);   tag.root_card.attribute_card('*template')
          else self
        end
    end
        
    def templatees
      if template? and trunk.class_name=='Cardtype'
        Card.const_get(trunk.extension.class_name).find(:all)
      elsif plus_template?
        tag.cards
      else
        []
      end
    end
    
    def ancestors
      node, nodes = self, []
      nodes << node = node.trunk until not node.trunk
      #has_trunk?
      nodes
    end
    
    def partner_of(card)
      return self if card.nil? or self.trunk.nil?
      case card
        when self.trunk;        self.tag.root_card
        when self.tag.root_card; self.trunk
        else self
      end
    end
    
    def pieces()  
      self.simple? ? [self] : [self, self.trunk.pieces, self.tag.root_card ].flatten.compact.uniq 
    end
    
    def root_cards()
      ([self] + self.ancestors).reverse.map {|p| p.tag.root_card } 
    end
      
    def cousins() 
      tag.cards.find :all, :conditions=>["id<>?",id], :order=>'id'
    end
  
    def relatives()
      @relatives ||= self.children(:order=>'id') + (simple? ? cousins : []) 
    end
    
    def dependents() 
      relatives.map { |r| [r ] + r.dependents }.flatten 
    end
    
    def cardtype
      @cardtype ||= ::Cardtype.find_by_class_name( class_name ).card
    end
    
    # 'connection' is reserved-- it's the database connection
    def attribute_card( name )
      Card.find_by_name( self.name + JOINT + name )
    end
   
   # Actions -------------------------------------------------------------------
    
    def connect( tag_card, content="", dry_run=false )
      raise Wagn::Oops, "Can't tag with connection cards" unless tag_card.simple?
      add_tag( tag_card.tag, content, dry_run )
    end
    
    def connect!( tag_card, content="", dry_run=false  )
      raise Wagn::Oops, "Can't tag with connection cards" unless tag_card.simple?
      add_tag!( tag_card.tag, content, dry_run )
    end
    
    def add_tag( new_tag, content="", dry_run=false )
      if c = Card.find_connection( self.name, new_tag.name )
        return c
      end
      self.add_tag!( new_tag, content, dry_run )
    end
    
    def add_tag!( new_tag, content="",dry_run=false )
      tag_card = new_tag.root_card
      raise Wagn::Oops, "Can't tag card with itself" if tag_card==self
      #warn "NAME #{self.name}  NEW NAME #{new_tag.name}"
      if c = Card.find_connection( self.name, new_tag.name )
        raise Wagn::Oops, "#{c.name} already exists"
      end
      
      # private cards can't be connected to private cards with a different group 
      new_reader, new_writer = self.reader, self.writer
      if self.private? and tag_card.private? and self.reader != tag_card.reader
        raise Wagn::PermissionDenied, "connect #{self.name} to #{tag_card.name} </br>\n" +
          "#{self.name} belongs to group #{self.reader.cardname}," +
          "while #{tag_card.name} belongs to group #{tag_card.reader.cardname}" +
          "and private cards can't be connected to private cards with a different group"
      elsif tag_card.private? and !self.private?
        new_reader, new_writer = tag_card.reader, tag_card.writer
      end
      
      options = {
        :trunk=>self,
        :tag=>new_tag,
        :content=>content,
        :reader=>new_reader,
        :writer=>new_writer
      }
      if dry_run then  Card::Basic.new( options ) else Card::Basic.create( options ) end
    end
  
    def clear_drafts
      connection.execute(%{
        delete from revisions where card_id=#{id} and id > #{current_revision_id} 
      })
    end
    
    def save_draft( content )
      clear_drafts
      revisions.create(:content=>content)
    end
    
    def revise( content )
      edit_ok! 
      if content == current_revision.content and !datatype.allow_duplicate_revisions
        raise Wagn::Oops.new( "Content was not changed" )
      end
      datatype.validate( content )
      content = datatype.before_save( content )
      if template != self
        raise ActiveRecord::RecordInvalid.new("Validation failed: Content of a templated card cannot be changed")
      end
      datatype.on_revise( content )
      
      
      # A user may change a card, look at it and make some more changes - several times.
      # Not to record every such iteration as a new revision, if the previous revision was done 
      # by the same author, not more than 30 minutes ago, then update the last revision instead of
      # creating a new one
      #if continous_revision?(time, author)
      #  current_revision.update_attributes( :content => content )
      #else 
      
      clear_drafts
      self.current_revision = Revision.create(:card_id=>self.id, :content => content)
      @revised = true
      save  # save current_revision_id
      @revised = false
      self
    end
  
    def rollback(revision_number)
      roll_back_revision = self.revisions[revision_number]
      if roll_back_revision.nil?
        raise Wagn::ValidationError.new("Revision #{revision_number} not found")
      end
      revise(roll_back_revision.content)
    end

    def flip_trunk_and_tag
      return false if trunk.trunk
      old_tag_card = tag.root_card
      self.tag = trunk.tag
      self.trunk = old_tag_card
      self.name = nil # trigger name generation
      self.save
    end    
    
    
    def landing_name
      self.name
    end
    
   private 
   
    # TODO: build the mechanism that will analyse existing taggings and 
    # set priority 
    def prioritize_card_and_tag_id(tag)
      [ self, tag.id ]  
    end
    
    def continous_revision?(time, author)
      #(current_revision.author == author) && (revised_at + 30.minutes > time)
      false
    end
    
    # ------------------------------------------------------------
    class << self   
      
      def find_or_create(name, args={})
        (c = Card.find_by_name(name)) ? c : Card.create(args.merge(:name=>name))
      end                      

      def create_with_wagn_api(args={})
        name = args[:name] || args['name']
        if name.nil? or name.simple?
          self.create_without_wagn_api args
        else
          Card.find_or_create( name.parent_name ).connect( Card.find_or_create(name.tag_name), args[:content] )
        end
      end
      alias_method_chain :create, :wagn_api
      
      def create_with_permissions(*args)    
        if permit_create?
          create_without_permissions(*args)
        else
          raise Wagn::PermissionDenied, "You don't have permission to create #{self.class_name} cards"
        end
      end
      alias_method_chain :create,  :permissions           
              
      def permit_create?()   System.ok?(:edit_cards)   end

       def find_connection( name1, name2 )
        self.find_by_name(name1 + JOINT + name2) or
          self.find_by_name(name2 + JOINT + name1)
      end
     
      def find_by_wql_options( options={} )
        wql = Wql.generate_query( options ) 
        self.find_by_wql( wql )
#      rescue Exception=>e
#        raise Wagn::WqlError, "Error from wql options: #{options.inspect}\n#{e.message}"
      end
      
      def find_by_wql( wql, options={})
        warn "find_by_wql: #{wql} " if System.debug_wql
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
      
      ## FIXME Hack to keep dynamic classes from breaking after application reload
      # in development..
      def find_with_rescue(*args)
        find_without_rescue(*args)
      rescue ActiveRecord::SubclassNotFound => e
        subclass_name = e.message.match( /subclass: '(\w+)'/ )[1]
        Card.const_get(subclass_name)
        # try one more time :-)
        find_without_rescue(*args)
      end
      alias_method :find_without_rescue, :find
      alias_method :find, :find_with_rescue    
      
      
      def tags_in_title(title)
        title.split(self.wiki_joint).map {|w| Tag.find_by_name(w.strip) }
      end
    end
  end
end

