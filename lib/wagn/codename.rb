module Wagn
 class Codename

  @@codehash=nil

  cattr_accessor :no_db

  class <<self
    def cardname from
      name = (card = case from
          when Integer; from
          when Symbol ; self[from.to_s]
        end and card.name or from)
      raise "Wagn::Codename.cardname class error: #{from.class} (#{from.inspect})" unless String === name
      name
    end

  private

    # FIXME: need a better source for bootstrap codenames
    YML_CODE_FILE = 'db/bootstrap/card_codenames.yml'

    def codehash() @@codehash || load_hash end

    # add a new entry, forward and reverse to the hash, checking for duplicates
    def hash_entry(cid, code)
      code = code.to_sym; cid =  cid.to_i
      if @@codehash.has_key?(code) or @@codehash.has_key?(cid)
        warn "dup code ID:#{cid} (#{@@codehash[code]}), CD:#{code} (#{@@codehash[cid]})"
      end
      @@codehash[code] = cid; @@codehash[cid] = code
    end

    def load_hash()
      @@codehash = {}

      # load from the card database table
      Card.where('codename is not NULL').each {|r| hash_entry(r.id, r.codename) }

      # seed the codehash so that we can bootstrap
      if @@no_db = @@codehash[:basic].nil?
        #warn Rails.logger.warn("yml load")
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
end
