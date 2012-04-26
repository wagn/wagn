class Card::Codename < ActiveRecord::Base
  cattr_accessor :cache


  class <<self
    def cardname from
      name = (card = case from
          when Integer; from
          when Symbol ; self[from.to_s]
        end and card.name or from)
      #warn "Codename#cardname(#{from}) #{name}, #{card}"
      raise "Card::Codename.name does not handle class: #{from.class} (#{from.inspect})" unless String === name
      name
    end

  private

    def codehash()
      r=
      self.cache.read('codehash') || begin
          load_cache
          self.cache.read('codehash')
        end
      warn "no codehash" if r.nil?; r
    end

    def load_cache()
      codehash = {}

      #warn "load_cache #{caller[0..3]*?\n}"
      Card.connection.select_all(%{ select card_id, codename from card_codenames
        }).each do |h|
          code = h['codename']; cid =  h['card_id'].to_i
          warn "dup code #{cid} #{codehash[cid]}, #{code} #{codehash[code]}" if codehash.has_key?(code) or codehash.has_key?(cid)
          codehash[code] = cid; codehash[cid] = code
        end

      #warn "setting cache: #{codehash.inspect}\n"
      self.cache.write 'codehash', codehash
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end

 public

    def [](code)
      raise "no codehash" if codehash.nil?
      warn "no code #{code} #{caller[0..8]*"\n"}" unless code =~ /^joe_/ or codehash.has_key? code.to_s
      codehash[code.to_s]      end
    def codename(id)
      #Rails.logger.warn "deprecate id2code #{caller[0..8]*"\n"}"
      #r=
      codehash[id]
      #warn "no code for id #{id.inspect}" if r.nil?; r
    end
    def name_change(key)                           end
    def codes()            codehash.each_key        end

    # FIXME: some tests need to use this because they add codenames, fix tests
    def reset_cache() self.cache.write('codehash', nil) end

  end
end
