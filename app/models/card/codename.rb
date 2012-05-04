class Card::Codename < ActiveRecord::Base

  @@codehash=nil

  cattr_accessor :no_db

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

    YML_CODE_FILE = 'test/fixtures/card_codenames.yml'
    def codehash() @@codehash || load_hash end

    def hash_entry(cid, code)
      code = code.to_sym; cid =  cid.to_i
      if @@codehash.has_key?(code) or @@codehash.has_key?(cid)
        warn "dup code ID:#{cid} (#{@@codehash[code]}), CD:#{code} (#{@@codehash[cid]})"
      end
      @@codehash[code] = cid; @@codehash[cid] = code
    end

    def load_hash()
      return @@codehash unless @@codehash.nil?
      @@codehash = {}

      Card.where('codename is not NULL').each {|r| hash_entry(r.id, r.codename) }

      if @@no_db = @@codehash.empty? # ugh, we seem to need this to load test fixtures
        warn Rails.logger.warn("yml load")
        if File.exists?( YML_CODE_FILE ) and yml = YAML.load_file( YML_CODE_FILE )
          yml.each { |p| hash_entry(p[1]['card_id'], p[1]['codename']) }
        else warn Rails.logger.warn("no file? #{YML_CODE_FILE}")
        end
      end
      #warn Rails.logger.warn("setting cache: #{@@codehash.inspect}\n")
      @@codehash
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end

 public

    def [](key)
      key = key.to_sym unless Integer===key
      codehash[key]
    end
    #def name_change(key)                                        end
    def codes()       codehash.each_key.find_all{|k|Symbol===k} end

    # FIXME: some tests need to use this because they add codenames, fix tests
    def reset_cache() @@codehash = nil end
  end
end
