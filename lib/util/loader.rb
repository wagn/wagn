require 'json'
require 'lib/util/card_builder'
module Wagn
  class Loader    
    def initialize(filename, args={})
      @filename = filename 
      @builder = CardBuilder.new  
      @cards = {}
      @cardinput = {}
      @authors = {}   
      @revisions = []
    end
    
    def load_yaml() load(:yaml) end
    def load_xml()  load(:xml)  end
    def load_json() load(:json) end
                     
    private
    
    def load( method) 
      open( @filename ) do |file|
        @revisions = 
          case method.to_sym
          when :xml; Hash.from_xml( file.read )['hash']['revisions']['revision']
          when :yaml; YAML::load( file.read )['revisions']
          when :json; JSON.parse( file.read )['revisions']
          end
               
        setup_import_user
        
        load_cards

        process_authors
                                
        #warn "processing titles..."
        #process_titles 
        
        process_revisions
        
        update_current_revisions
        
      end   
    end
                          
    def setup_import_user
      @builder.as( @builder.admin ) do 
        @import_user = @builder.create_user( "Importer" )
        @import_user.roles << Role.find_by_codename('admin')
      end                             
      Card.user = @import_user
    end
        
    def process_authors
      @revisions.collect {|r| r['author'] }.uniq.each do |author_name|
        @authors[author_name] = @builder.create_user( author_name )
      end
    end
      
    def load_cards
      # FIXME: you can't create a card without creating a revision,
      # so we create a bunch of bogus Importer revisions
      @revisions.each do |rev|
	@cardinput[rev['name']] = rev
      end
    end

    def process_titles
      # FIXME: you can't create a card without creating a revision,
      # so we create a bunch of bogus Importer revisions
      @revisions.sort_by {|r| r['name'].length}.each do |rev|
        if not @cards[rev['name']]
          create_card(rev)
        end
      end
    end

    def create_card(rev)
      title = rev['name']
      warn("process Ti: "+title)
      c = @cards[title] = Card.find(:first, :conditions => "name='"+title+"'")
      if not c
        create_type(rev['type'])
        warn("New card for name: "+title)
        c = @cards[title] = Card.create!(:name => title, :type => rev['type'])
        if not c
          warn("New card not created: "+title)
        end
      end
      c
    end

    def create_type(ctype)
      warn("process Ty: "+ctype)
      if not @cards[ctype]
        c = @cards[ctype] = Card.find(:first, :conditions => "name='"+ctype+"'")
        if not c
          warn("New card type name: "+ctype)
           
          warn("create Ty: "+ctype)
          c = @cards[ctype] = Card.create!(:name => ctype, :type => 'Cardtype')
          c.save!
          if not c
            warn("New type card not created: "+ctype)
          end
        else
          warn("Found type: "+ctype)
        end
      else
        warn("Have type: "+ctype)
      end
    end

    def update_current_revisions 
      @cards.values.each do |c|
        warn("Saving last "+c.card.name)
        c.current_revision = c.revisions(refresh=true).last
        c.save
      end
    end
    
    def process_revisions     
      @revisions.sort_by{|r| r['date']}.each do |rev|
        data = {
          :card_id => @cards[rev['name']].id,
          :content => rev['content'] || ''  ,
          :created_at => rev['date'],
          :creator_id => @authors[rev['author']]
        }      
        # FIXME: should check if this might be a duplicate revision
        Card::Revision.create! data
      end
    end
  end
end
