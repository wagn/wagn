module Wagn
 class Codename

  @@codehash=nil

  class <<self
    def cardname from
      name = (card = case from
          when Integer; from
          when Symbol ; self[from.to_s]
        end and card.name or from)
      raise "Wagn::Codename.cardname class error: #{from.class} (#{from.inspect})" unless String === name
      name
    end

    def bootdata(hash) @@codehash = hash end

  private

    def codehash() @@codehash || load_hash end

    def load_hash()
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
