module Wagn
  class Codename
    cattr_accessor :cache
    @@pre_cache = {}

    class <<self

      def [](code)           card_attr(code, :name)      end
      def codename(key)      code_attr(key, :codename)   end
      def id_from_code(code) card_attr(code, :id)        end
      def exists?(key)       code_attr(key)              end
      def name_change(key)   exists?(key) && reset_cache end 
      def codes()            get_cache(:code2card).each_value      end
      def type_codes()
=begin
        c=get_cache(:code2card)
        warn "type_codes #{c.nil? ? "caller:#{caller*"\n"}" : "keys #{c.keys*"\n"}"}"
        r=c.values.find_all {|h|
          warn "type_search #{h[:type_id]==cardtype_type_id}, #{h.inspect}"
          h[:type_id]==cardtype_type_id
        }
        warn "type_codes R:#{r.inspect}"; r
=end
        get_cache(:code2card).values.find_all {|h| h[:type_id]==cardtype_type_id}
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

      def default_type_id()  @@default_id  ||= id_from_code('Basic')    end
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
            h[:codename] ||= Card.klassname_for(h[:name])
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
