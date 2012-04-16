class Card::Codename < ActiveRecord::Base
  cattr_accessor :cache

    
  class <<self
    def cardname from
      case from
      when Integer; code_attr from, :name
      when Symbol ; card_attr from.to_s, :name
      when String ; from
      else; raise "Card::Codename.name does not handle class: #{from.class}"
      end
    end

    def [](code)           card_attr(code.to_s, :name)      end
    def codename(key)      code_attr(key, :codename)        end
    def code2id(code)      card_attr(code, :id)             end
    def exists?(key)       code_attr(key)                   end
    def name_change(key)   exists?(key) && reset_cache      end 
    def codes()            get_cache('code2card').each_value end

    def code_attr(key, attr=nil?)
      #warn "miss #{key} #{card2code.map(&:inspect)*"\n"}" unless card2code.has_key?(key)
      card2code &&
      card2code.has_key?(key) && (attr ? card2code[key][attr] : true)
    end

    def card_attr(key, attr=nil?)
      unless hsh = code2card
        #raise "no code2card hash #{key} #{attr}"
        warn "no code2card hash #{key} #{attr} #{caller*?\n}"
        return
      end
      #warn "card_attr(#{key}, #{attr}) #{hsh.size}"
      #warn "miss card_attr(#{key}, #{attr}) code2card:#{hsh.size}" unless hsh.has_key?(key) or %w{joe_user joe_admin u1 u2 u3 john}.member?(key.to_s)
      hsh.has_key?(key) && (attr ? hsh[key][attr] : true)
    end

    def reset_cache()
      set_cache('card2code', nil)
      set_cache('code2card', nil)
    end

  private

    def card2code() get_cache('card2code') end
    def code2card() get_cache('code2card') end

    def get_cache(cname)
      raise "cache missing (set) #{cname}" unless self.cache
      unless hsh=self.cache.read(cname)
        #warn "load_cache(#{cname})"
        load_cache
        hsh = self.cache.read(cname)
        #warn "??? #{cname}, (loaded) #{hsh.nil? ? 0 : hsh.size}, #{self.cache.read(cname).class}"
      end
      raise "??? #{cname}, #{hsh.inspect}, #{self.cache.read cname}" unless Hash===hsh; hsh
      #raise "??? #{cname}, #{hsh.size}, #{self.cache.read cname}" if cname == 'code2card' && hsh.size > 200; hsh
      #warn "get_cache(#{cname}) => #{hsh.class}: #{hsh.nil? ?  (caller*?\n) : hsh.size}"; hsh
    end

    def set_cache(cname, v)
      cname = cname.to_s
      #warn "set_cache(#{cname.inspect}), #{self.cache.class}, #{v ? v.size : 0}"
      raise "cache missing (set) #{cname}" unless self.cache
      self.cache.write(cname, v)
    end

    def load_cache()
      card2code = {}; code2card = {}

      #warn "load_cache #{caller[0..3]*?\n}"
      Card.connection.select_all(%{
          select c.id, c.name, c.key, cd.codename
           from card_codenames cd, cards c where c.id = cd.card_id
        }).map(&:symbolize_keys).each do |h|
          h[:id] = h[:id].to_i
          #warn "codename #{h.inspect}"
          code2card[h[:codename]] = card2code[h[:id]] = card2code[h[:key]] = h
        end

      #warn "setting caches: #{code2card.inspect}\n#{card2code.inspect}\n"
      set_cache 'code2card', code2card
      set_cache 'card2code', card2code
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end
  end

  @@default_id = @@cardtype_id = nil
end
