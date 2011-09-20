module Wagn
  class Codename
    @@code_cache = nil

    class <<self
      def code_cache()
        @@code_cache ||= load_cache()
      end

      # This is a read-only cached model.  Entries must be added on bootstrap,
      # or as an administrative action when installing or upgrading wagn and
      # its packs.
      def insert(card_id, codename)
        Card.connection.insert(%{
          insert into codename (card_id, codename) values (#{card_id}, '#{codename}')
        })
      end

      def load_cache()
        cache = {}
        Card.connection.select_all(%{
           select c.id, c.name, c.key, cd.codename
             from cards c join codename cd on c.id = cd.card_id
            where c.trash is false
          }).each do |rec|
          Rails.logger.info "Loading codenames #{rec.inspect}"
           id, key = rec['id'], rec['key']
           cache[id] = cache[key] = {:name => rec['name'], :id => id,
                         :codename => rec['codename'], :key => key}
        end
        cache
      rescue
        Rails.logger.info "Error loading codenames"
      end

      def codename(key)  
        x = code_cache; y = x[key]; z = y and y[:codename]
        Rails.logger.info "Codename[#{key}]: #{x}, #{y}, #{z}"
        e=code_cache[key] and e[:codename] end
      def codeid(key) 
        x = code_cache; y = x[key]; z = y and y[:id]
        Rails.logger.info "Codenme id[#{key}]: #{x}, #{y}, #{z}"
        e=code_cache[key] and e[:id]       end
      def name_of_code(key) key end
=begin
        Rails.logger.info "Codename name from code[#{key}]: #{code_cache.inspect}"
        x = code_cache; y = x[key]; z = y and y[:name]
        Rails.logger.info "Codename name from code[#{key}]: #{x}, #{y}, #{z}"
        e=code_cache[key] and e[:name]     end
=end
    end
  end
end
