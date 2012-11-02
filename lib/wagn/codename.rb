module Wagn
 class Codename

  @@codehash=nil

  class << self
    # returns codename for id and vice versa.  not in love with this api --efm
    def [] key
      key = key.to_sym unless Integer===key
      codehash[key]
    end

    def codehash
      @@codehash || load_hash
    end

    def reset_cache
      @@codehash = nil
    end

    #only used in migration
    def bootdata hash
      @@codehash = hash
    end


    private

    def load_hash
      @@codehash = {}

      Card.where('codename is not NULL').each do |r|
        #FIXME: remove duplicate checks, put them in other tools
        code, cid = r.codename.to_sym, r.id.to_i
        if @@codehash.has_key?(code) or @@codehash.has_key?(cid)
          warn "dup code ID:#{cid} (#{@@codehash[code]}), CD:#{code} (#{@@codehash[cid]})"
        end
        @@codehash[code] = cid; @@codehash[cid] = code
      end

      @@codehash
    end
  end
 end
end
