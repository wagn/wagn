class Card::Codename < ActiveRecord::Base

  class <<self
    def cardname from
      name = (card = case from
          when Integer; from
          when Symbol ; self[from.to_s]
        end and card.name or from)
      raise "Card::Codename.cardname class error: #{from.class} (#{from.inspect})" unless String === name
      name
    end

  private

    def codehash() @codehash || load_cache end

    def load_cache()
      return @codehash unless @codehash.nil?
      @codehash = {}

      Card.connection.select_all(%{ select card_id, codename from card_codenames }).each do |h|
          code = h['codename'].to_sym; cid =  h['card_id'].to_i
          warn "dup code ID:#{cid} (#{@codehash[code]}), CD:#{code} (#{@codehash[cid]})" if @codehash.has_key?(code) or @codehash.has_key?(cid)
          @codehash[code] = cid; @codehash[cid] = code
        end

      #warn "setting cache: #{@codehash.inspect}\n"
      @codehash
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end

 public

    def [](key)
      key = key.to_sym unless Integer===key
      #warn "no key #{key.inspect} #{caller[0..8]*"\n"}" unless Integer===key or [:banana_pudding, :county, :cookie, :joe_user, :joe_admin, :john, :u1].member?(key) or codehash.has_key? key
      codehash[key]
    end
    alias codename []
    #def codename(id)       codehash[id]                        end
    def name_change(key)                                       end
    def codes()          codehash.each_key.find{|k|Symbol===k} end

    # FIXME: some tests need to use this because they add codenames, fix tests
    def reset_cache() @codehash = nil end
  end
end
