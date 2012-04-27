class Card::Codename < ActiveRecord::Base
  cattr_accessor :cache


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
      return @codehash unless (@codehash = self.cache.read 'codehash').nil?
      @codehash = {}

      Card.connection.select_all(%{ select card_id, codename from card_codenames }).each do |h|
          code = h['codename']; cid =  h['card_id'].to_i
          warn "dup code ID:#{cid} (#{@codehash[code]}), CD:#{code} (#{@codehash[cid]})" if @codehash.has_key?(code) or @codehash.has_key?(cid)
          @codehash[code] = cid; @codehash[cid] = code
        end

      #warn "setting cache: #{@codehash.inspect}\n"
      self.cache.write 'codehash', @codehash
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end

 public

    def [](code)
      #warn "no code #{code} #{caller[0..8]*"\n"}" unless %w{joe_user joe_admin john u1}.
                                           member?(code) or codehash.has_key? code.to_s
      codehash[code.to_s]
    end
    def codename(id)       codehash[id]             end
    def name_change(key)                            end
    def codes()            codehash.each_key        end

    # FIXME: some tests need to use this because they add codenames, fix tests
    def reset_cache() @codehash = self.cache.write('codehash', nil) end
  end
end
