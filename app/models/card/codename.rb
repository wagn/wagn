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

    def [](code)
      #warn "no code #{code} #{caller[0..8]*"\n"}" unless code =~ /^joe_/ or code2id.has_key? code.to_s
      code2id[code.to_s]      end
    def codename(id)
      #Rails.logger.warn "deprecate id2code #{caller[0..8]*"\n"}"
      code2id.each { |c, i| return c if i == id }
      #warn "no code for id #{id.inspect}"
      nil
    end
    def name_change(key)                           end
    def codes()            code2id.each_key        end

    # FIXME: some tests need to use this because they add codenames, fix tests
    def reset_cache() self.cache.write('code2id', nil) end

  private

    def code2id
      #r=
      self.cache.read('code2id') || begin
          load_cache
          self.cache.read('code2id')
        end
      #warn "c2id #{r.inspect}"; r
    end

    def load_cache()
      code2id = {}

      #warn "load_cache #{caller[0..3]*?\n}"
      Card.connection.select_all(%{ select card_id, codename from card_codenames
        }).each { |h| code2id[h['codename']] = h['card_id'].to_i }

      #warn "setting cache: #{code2id.inspect}\n"
      self.cache.write 'code2id', code2id
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end
  end
end
