module Cardlib
  module Search
    module ClassMethods

      def add_builtin(card)     
        card.builtin = true
        card.missing = false
        card.virtual = true
        Card.cache.write(card.key, card)
        @@builtins[card.key] = card
      end
      
     def pattern_virtual(name)
        return nil unless name && name.junction?
        if template = Card.new(:name=>name, :skip_defaults=>true).template and template.hard_template? 
          User.as(:wagbot) do
            Card.create_virtual name, template.content, template.type
          end
        elsif System.ok?(:administrate_users) and name.tag_name =~ /^\*(email)$/
          attr_name = $~[1]
          content = Card.retrieve_extension_attribute( name.trunk_name, attr_name ) || ""
          User.as(:wagbot) do
            Card.create_virtual name, content  
          end
        else
          return nil
        end
      end
      alias find_virtual pattern_virtual

      def retrieve_extension_attribute( cardname, attr_name )
        c = Card.fetch(cardname) and e = c.extension and e.send(attr_name)
      end

      def create_virtual(name, content, type='Basic', reader=Role[:anon])
        Card.new(:name=>name, :content=>content, :type=>type ,:reader=>reader, :virtual=>true, :skip_defaults=>true)
      end
      
      def count_by_wql(spec)       
        #.gsub(/^\s*\(/,'').gsub(/\)\s*$/,'')
        spec.delete(:offset)
        result = connection.select_one( Wql::CardSpec.build(spec).merge(:return=>'count').to_sql )
        (result['count'] || result['count(*)']).to_i
      end

      def search(spec) 
        Wql.new(spec).run
      end

      def find_by_name( name, opts={} ) 
        self.find_by_key_and_trash( name.to_key, false, opts.merge( :include=>:current_revision ))
      end

      def [](name) 
         Card.fetch(name, :skip_virtual => true)
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
       
      # FIXME: this is f'ed up-- why does this break everything?
      #alias_method_chain :find, :rescue  
    end
    
    def update_search_index     
      return unless (@search_content_changed && 
          System.enable_postgres_fulltext && Card.columns.plot(:name).include?("indexed_content"))
      
      connection.execute %{
        update cards set indexed_content = concat( setweight( to_tsvector( name ), 'A' ), 
        to_tsvector( (select content from revisions where id=cards.current_revision_id) ) ),
        indexed_name = to_tsvector( name ) where id=#{self.id}
      }
      @search_content_changed = false
      true
    end

    def self.append_features(base)   
      super
      Card::Base.extend(ClassMethods)
      Card.extend(ClassMethods)    
      base.after_save :update_search_index
      base.class_eval do
        cattr_accessor :skip_index_updates
      end
    end

  end
end
