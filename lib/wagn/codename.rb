module Wagn
  class Codename
    cattr_accessor :cache
    @@pre_cache = {}

    class <<self

      def [](code)           card_attr(code, :name)      end
      def codename(key)      code_attr(key, :codename)   end
      def id_from_code(code) code_attr(code, :id)        end
      def exists?(key)       code_attr(key)              end
      def name_change(key)   exists?(key) && reset_cache end 
      def codes()            get_cache('code2card').each_value      end
      def type_codes() get_cache('code2card').find { |h| h[:type_id] == cardtype_type_id } end

      # This is a read-only cached model.  Entries must be added on bootstrap,
      # or as an administrative action when installing or upgrading wagn and
      # its packs.
      def insert(card_id, codename)
        Card.connection.insert(%{
          insert into codename (card_id, codename) values (#{card_id}, '#{codename}')
        })
        reset_cache
      end

      def code_attr(key, attr=nil?)
        card2code.has_key?(key) && (attr ? card2code[key][attr] : true)
      end

      def card_attr(key, attr=nil?)
        code2card.has_key?(key) && (attr ? code2card[key][attr] : true)
      end

      def default_type_id()  @@default_id ||= id_from_code('Basic') end
      def cardtype_type_id() @@cardtype_id ||= id_from_code('Cardtype') end

      def reset_cache()
        set_cache('card2code', nil)
        set_cache('code2card', nil)
      end

    private

      def card2code()   get_cache('card2code') end
      def code2card()   get_cache('code2card') end

      def get_cache(key)
        if self.cache
          return c if c = self.cache.read(key)
          load_cache
          return self.cache.read(key)
        else
          return c if c = @@pre_cache[key]
          load_cache
          @@pre_cache[key]
        end
      end

      def set_cache(key, v)
        self.cache ? self.cache.write(key, v) : @@pre_cache[key] = v
      end

      def load_cache()
        card2code = {}; code2card = {}

        Card.connection.select_all(%{
            select c.id, c.name, c.key, cd.codename, c.type_id
             from cards c left outer join codename cd on c.id = cd.card_id
            where c.trash is false
              and (c.type_id = 5 or cd.codename is not null)
          }).map(&:symbolize_keys).each do |h|
            h[:id] = h[:id].to_i
            h[:codename] ||= Card.klassname_for(h[:name])
            code2card[h[:codename]] = card2code[h[:id]] = card2code[h[:key]] = h
          end

        set_cache 'code2card', code2card
        set_cache 'card2code', card2code
        #warn "loaded code2card #{code2card.map{|v|v.inspect}*"\n"}"
        #warn "loaded card2code #{card2code.map{|v|v.inspect}*"\n"}"
      rescue Exceptions => e
        warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
      end
    end

    @@default_id = @@cardtype_id = nil
  end
end
