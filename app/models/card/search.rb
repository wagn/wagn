module CardLib
  module Search
    module ClassMethods 
      def find_phantom(name)     
        #ActiveRecord::Base.logger.info("CACHE in find_phantom #{name}")
        
        if name=='*recent changes'
          c = Card::Search.new( :name=>"*recent changes", :content=>%{{"sort":"update", "dir":"desc"}})
          #c.send(:set_defaults)    
          c.phantom = true
          return c
        end
        if name=='*search'
          c = Card::Search.new( :name=>"*search", :content=>%{{"match":"_keyword", "sort":"relevance"}})
          #c.send(:set_defaults)    
          c.phantom = true
          return c
        end
        
        template_tsar_name = name.simple? ? name : name.tag_name
        template = Card.search( :type=>'Search', :name=>"#{template_tsar_name}+*template" )[0]
        return nil unless template
        
        c = Card::Search.new :name=>name, :content=>template.content
        #c.send(:set_defaults)
        if name.junction?
          c.self_card = c.trunk 
          #warn "setting search card #{c.trunk}"
        end
        c.phantom = true
        c
      end

      def count_by_wql(spec)       
        #.gsub(/^\s*\(/,'').gsub(/\)\s*$/,'')
        result = connection.select_one( Wql2::CardSpec.new(spec).merge(:return=>'count').to_sql )
        (result['count'] || result['count(*)']).to_i
      end

      def search(spec) 
        #ActiveRecord::Base.logger.info("  search #{spec.to_s}")
        Card.find_by_sql( Wql2::CardSpec.new(spec).to_sql )
      end

      #def find_by_json(spec)
      #  Card.find_by_sql( Wql2::CardSpec.new( JSON.parse(spec) ).to_sql )
      #end

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
       
      # FIXME: this is fucked up-- why does this break everything?
      #alias_method_chain :find, :rescue  
    end
    
    def update_search_index
      return unless (@search_content_changed && 
          System.enable_postgres_fulltext && Card.columns.plot(:name).include?("indexed_content"))
      
      connection.execute %{
        update cards set indexed_content = concat( setweight( to_tsvector( name ), 'A' ), 
        to_tsvector( (select content from revisions where id=cards.current_revision_id) ) ) 
        where id=#{self.id}
      }
      @search_content_changed = false
      true
    end

    def self.included(base)   
      super
      base.extend(ClassMethods)    
      base.after_save :update_search_index
      base.class_eval do
        cattr_accessor :skip_index_updates
      end
    end

  end
end