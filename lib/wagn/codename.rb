module Wagn
  class Codename
    cattr_accessor :cache
    @@pre_cache = {}

    class <<self

      def [](code)           card_attr(code, :name)      end
      def codename(key)      code_attr(key, :codename)   end
      def code2id(code) card_attr(code, :id)        end
      def exists?(key)       code_attr(key)              end
      def name_change(key)   exists?(key) && reset_cache end 
      def codes()            get_cache(:code2card).each_value      end
      def type_codes()
        get_cache(:code2card).values.find_all {|h| h[:type_id]==Card::CardtypeID}
      end

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
        #warn "miss #{key} #{card2code.map(&:inspect)*"\n"}" unless card2code.has_key?(key)
        card2code.has_key?(key) && (attr ? card2code[key][attr] : true)
      end

      def card_attr(key, attr=nil?)
        #warn "miss card #{key} #{code2card.map(&:inspect)*"\n"}" unless code2card.has_key?(key)
        code2card.has_key?(key) && (attr ? code2card[key][attr] : true)
      end

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
          return c if c = @@pre_cache[key.to_s]
          load_cache
          @@pre_cache[key.to_s]
        end
      end

      def set_cache(key, v)
        key = key.to_s
        #warn "set_cache(#{key.inspect}, #{v.inspect})"
        #warn "no value set_cache #{key.inspect}, #{caller[0..20]*"\n"}" if v.nil? or v.blank?
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
            h[:type_id], h[:id] = h[:type_id].to_i, h[:id].to_i
            h[:codename] ||=
              Card.respond_to?(:klassname_for) ? Card.klassname_for(h[:name]) : h[:name]
            code2card[h[:codename]] = card2code[h[:id]] = card2code[h[:key]] = h
          end

        set_cache 'code2card', code2card
        set_cache 'card2code', card2code
        #warn "loaded code2card #{code2card.map(&:inspect)*"\n"}"
        #warn "loaded code2card #{code2card.map{|k,v|k=~/^[A-Z]/ && "#{k}->#{v.inspect}"}.compact*"\n"}"
        #warn "loaded card2code #{card2code.map{|v|v.inspect}*"\n"}"
      rescue Exceptions => e
        warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
      end
    end

    @@default_id = @@cardtype_id = nil
  end
end
