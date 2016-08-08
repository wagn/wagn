# -*- encoding : utf-8 -*-
require_dependency "card/cache"
require_dependency "card/name"

class Card
  class Codename
    @@codehash = nil

    class << self
      # returns codename for id and vice versa.  not in love with this api --efm
      def [] key
        return if key.nil?
        key = key.to_sym unless key.is_a? Integer
        codehash[key]
      end

      def codehash
        @@codehash || load_hash
      end

      def reset_cache
        @@codehash = nil
        cache.write "CODEHASH", nil
      end

      # only used in migration
      def bootdata hash
        @@codehash = hash
      end

      private

      def cache
        Card::Cache[Codename]
      end

      def each_codenamed_card
        sql = "select id, codename from cards where codename is not NULL"
        ActiveRecord::Base.connection.select_all(sql).each do |row|
          yield row["codename"].to_sym, row["id"].to_i
        end
      end

      def check_duplicates codehash, codename, card_id
        # FIXME: remove duplicate checks here; should be caught upon creation
        return unless codehash.key?(codename) || codehash.key?(card_id)
        warn "dup code ID:#{card_id} (#{codehash[codename]}), " \
             "CD:#{codename} (#{codehash[card_id]})"
      end

      def load_hash
        @@codehash = cache.read("CODEHASH") || begin
          codehash = {}
          each_codenamed_card do |codename, card_id|
            check_duplicates codehash, codename, card_id
            codehash[codename] = card_id
            codehash[card_id] = codename
          end
          cache.write "CODEHASH", codehash
        end
      end
    end
  end

  def self.const_missing const
    if const.to_s =~ /^([A-Z]\S*)ID$/ &&
       (code = Regexp.last_match(1).underscore.to_sym)
      if (card_id = Codename[code])
        const_set const, card_id
      else
        raise "Missing codename #{code} (#{const})"
      end
    else
      super
    end
  end
end
