module CardLib
  module Search
    module ClassMethods 
      def find_builtin(name)
        key=name.to_key
        searches =  
          { '*recent_change' => %{ {"sort":"update", "dir":"desc", "view":"change"} },
            '*search'        => %{ {"match":"_keyword", "sort":"relevance"        } },
            '*broken_link'   => %{ {"link_to":"_none"                             } },
            '*user'          => %{ {"extension_type":"User"                       } },
          }
        case 
          when searches[key];
            create_phantom(name, searches[key], 'Search')
        end
      end
      
      def find_phantom(name)  
        find_builtin(name) or begin 
          auto_card(name)
        end   
      end

      def auto_card(name)
        return nil if name.simple?
        template = (Card.right_template(name) || Card.multi_type_template(name))
        if template and template.hard_template?    
          User.as(:wagbot) do
            Card.create_phantom name, template.content
          end
        elsif System.ok?(:administrate_users) and name.tag_name =~ /^\*(email)$/
          attr_name = $~[1]
          content = Card.retrieve_extension_attribute( name.trunk_name, attr_name ) || ""
          User.as(:wagbot) do
            Card.create_phantom name, content  
          end
        else
          return nil
        end
      end

      def retrieve_extension_attribute( cardname, attr_name )
        c = Card.find_by_name(cardname) and e = c.extension and e.send(attr_name)
      end

      def create_phantom(name, content, type='Basic', reader=Role[:anon])
        c=Card.new(:name=>name, :content=>content, :type=>type ,:reader=>reader, :phantom=>true)
        c
      end
      
      def count_by_wql(spec)       
        #.gsub(/^\s*\(/,'').gsub(/\)\s*$/,'')
        spec.delete(:offset)
        result = connection.select_one( Wql2::CardSpec.new(spec).merge(:return=>'count').to_sql )
        (result['count'] || result['count(*)']).to_i
      end

      def search(spec) 
        sql = Wql2::CardSpec.new(spec).to_sql
        results = Card.find_by_sql( sql )
        #warn ">>>>>>>>SPEC: #{spec.inspect}"
        #warn ">>>>>>>>SQL: #{sql.inspect}"
        if spec[:prepend] || spec[:append]
          if context_card = spec[:_card]
            context_name = context_card.simple? ? context_card.name : context_card.name.trunk_name
            spec[:prepend] &&= spec[:prepend].to_absolute(context_name)
            spec[:append]  &&= spec[:append].to_absolute(context_name)
          end
          results = results.map do |card|             
            CachedCard.get [spec[:prepend], card.name, spec[:append]].compact.join('+')
          end
        end
        results
      end
      
      #def find_by_json(spec)
      #  Card.find_by_sql( Wql2::CardSpec.new( JSON.parse(spec) ).to_sql )
      #end

      def find_by_name( name, opts={} ) 
        self.find_by_key_and_trash( name.to_key, false, opts )
      end

      def find_by_wql_options( options={} )
        raise("Deprecated: old wql")
      end

      def find_by_wql( wql, options={})
        raise("Deprecated: old wql")
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
      base.extend(ClassMethods)    
      base.after_save :update_search_index
      base.class_eval do
        cattr_accessor :skip_index_updates
      end
    end

  end
end