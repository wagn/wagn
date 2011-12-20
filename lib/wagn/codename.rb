module Wagn
  class Codename
    @@card2code = nil
    @@code2card = nil

    class <<self

      def [](code)         card_attr(code, :name)      end
      #def codeid(code)     card_attr(code, :id)        end
      def codename(key)    code_attr(key, :codename)   end
      def exists?(key)     code_attr(key)              end
      def name_change(key) exists?(key) && reset_cache end 

      # This is a read-only cached model.  Entries must be added on bootstrap,
      # or as an administrative action when installing or upgrading wagn and
      # its packs.
      def insert(card_id, codename)
        Card.connection.insert(%{
          insert into codename (card_id, codename) values (#{card_id}, '#{codename}')
        })
        reset_cache
      end

    private

      def reset_cache() @@card2code=nil              end
      def card2code()   @@card2code ||= load_cache() end
      def code2card()   card2code; @@code2card       end
      def load_cache()
        cache = {}
        codecache = {}
        Card.connection.select_all(%{
           select c.id, c.name, c.key, cd.codename
             from cards c join codename cd on c.id = cd.card_id
            where c.trash is false
          }).each do |rec|
          (Rails.logger.info "Loading codenames #{rec.inspect}")
           codename, id, key = rec['codename'], rec['id'].to_i, rec['key']
           codecache[codename]= cache[id]= cache[key] = {:name => rec['name'], 
             :key => key, :id => id, :codename => codename}
        end
        #warn "loaded codename code2card #{codecache.map{|v|v.inspect}*"\n"}"
        #warn "loaded codename card2code #{cache.map{|v|v.inspect}*"\n"}"
        @@code2card=codecache
        @@card2code=cache
      rescue
        warn(Rails.logger.info "Error loading codenames")
      end

      def code_attr(key, attr=nil?)
        z= card2code.has_key?(key) && (attr ? card2code[key][attr] : true)
        #warn "code_attr(#{key}, #{attr}) #{z}"; z
      end

      def card_attr(key, attr=nil?)
        z= code2card.has_key?(key) && (attr ? code2card[key][attr] : true)
        #warn "card_attr(#{key}, #{attr}) #{z}"; z
      end

    end
  end
end
