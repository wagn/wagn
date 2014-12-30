# -*- encoding : utf-8 -*-
require_dependency 'card/cache'
require_dependency 'card/name'

class Card
  class Codename

    @@codehash=nil

    class << self
      # returns codename for id and vice versa.  not in love with this api --efm
      def [] key
        if !key.nil?
          key = key.to_sym unless Integer===key
          codehash[key]
        end
      end

      def codehash
        @@codehash || load_hash
      end

      def reset_cache
        @@codehash = nil
        cache.write 'CODEHASH', nil
      end

      #only used in migration
      def bootdata hash
        @@codehash = hash
      end
      
  
      private
      
      def cache
        Card::Cache[Codename]
      end

      def load_hash
        @@codehash = cache.read('CODEHASH') || begin
          codehash = {}
          sql = 'select id, codename from cards where codename is not NULL'
          ActiveRecord::Base.connection.select_all(sql).each do |row|
            #FIXME: remove duplicate checks, put them in other tools
            code, cid = row['codename'].to_sym, row['id'].to_i
            if codehash.has_key?(code) or codehash.has_key?(cid)
              warn "dup code ID:#{cid} (#{codehash[code]}), CD:#{code} (#{codehash[cid]})"
            end
            codehash[code] = cid; codehash[cid] = code
          end
          cache.write 'CODEHASH', codehash
        end
      end
    end
    
  end
  
  
  def self.const_missing const
    if const.to_s =~ /^([A-Z]\S*)ID$/ and code=$1.underscore.to_sym
      if card_id = Codename[code]
        const_set const, card_id
      else
        raise "Missing codename #{code} (#{const})"
      end
    else
      super
    end
  end
  
end
