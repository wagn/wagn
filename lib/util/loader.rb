require 'json'
require 'lib/util/card_builder'
module Wagn
  class Loader    
    def initialize(filename, args={})
      @filename = filename 
      @builder = CardBuilder.new  
      @cards = {}
      @authors = {}   
      @revisions = []
    end
    
    def load_yaml() load(:yaml) end
    def load_xml()  load(:xml)  end
    def load_json() load(:json) end
                     
    private
    
    def load( method) 
      open( @filename ) do |file|
        warn "parsing file..."
        @revisions = 
          case method.to_sym
          when :xml; Hash.from_xml( file.read )['hash']['revisions']['revision']
          when :yaml; YAML::load( file.read )['revisions']
          when :json; JSON.parse( file.read )['revisions']
          end
               
        setup_import_user
        
        warn "processing authors..."      
        process_authors
                                
        warn "processing titles..."
        process_titles 
        
        warn "processing revisions..."
        process_revisions
        
        warn "finalizing cards..."
        update_current_revisions
        
        warn "done"
      end   
    end
                          
    def setup_import_user
      @builder.as( @builder.admin ) do 
        @import_user = @builder.create_user( "Importer" )
        @import_user.roles << Role.find_by_codename('admin')
      end                             
      User.current_user = @import_user
    end
        
    def process_authors
      @revisions.collect {|r| r['author'] }.uniq.each do |author_name|
        @authors[author_name] = @builder.create_user( author_name )
      end
    end
      
    def process_titles
      # FIXME: you can't create a card without creating a revision,
      # so we create a bunch of bogus Importer revisions
      @revisions.collect {|r| r['name'] }.uniq.sort_by {|t| t.length}.each do |title|
        @cards[title] = @builder.create_compound( title )
      end
    end

    def update_current_revisions 
      @cards.values.each do |c|
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
          :created_by => @authors[rev['author']]
        }      
        # FIXME: should check if this might be a duplicate revision
        Revision.create! data
      end
    end
  end
end