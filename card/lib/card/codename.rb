# -*- encoding : utf-8 -*-
require_dependency "card/cache"
require_dependency "card/name"

class Card
  # {Card}'s names can be changed, and therefore names should not be directly
  # mentioned in code, lest a name change break the application. Instead, a
  # {Card} that needs specific code manipulations should be given a {Codename},
  # a unique string identifier that will not change even if the card's name
  # does.
  #
  # The {Codename} class provides a fast cache for this slow-changing data.
  # Every process maintains a complete cache that is not frequently reset
  #
  # Generally speaking, _codenames_ are represented by Symbols, _names_ are
  # Strings, and _ids_ are Integers.
  #
  class Codename
    class << self
      # returns codename for id and id for codename
      # @param key [Integer, String]
      # @return [String, Integer]
      def [] key
        return if key.nil?
        codehash[key.is_a?(Integer) ? key : key.to_sym]
      end

      # a Hash in which String keys have Integer values and vice versa
      # @return [Hash]
      def codehash
        @codehash ||= load_codehash
      end

      # clear cache both locally and in cache
      def reset_cache
        @codehash = nil
        Card.cache.delete "CODEHASH"
      end

      private

      # iterate through every card with a codename
      # @yieldparam codename [Symbol]
      # @yieldparam id [Integer]
      def each_codenamed_card
        sql = "select id, codename from cards where codename is not NULL"
        ActiveRecord::Base.connection.select_all(sql).each do |row|
          yield row["codename"].to_sym, row["id"].to_i
        end
      end

      # @todo remove duplicate checks here; should be caught upon creation
      def check_duplicates codehash, codename, card_id
        return unless codehash.key?(codename) || codehash.key?(card_id)
        warn "dup code ID:#{card_id} (#{codehash[codename]}), " \
             "CD:#{codename} (#{codehash[card_id]})"
      end

      # generate Hash for @codehash and put it in the cache
      def load_codehash
        Card.cache.fetch("CODEHASH") do
          generate_codehash
        end
      end

      def generate_codehash
        hash = {}
        each_codenamed_card do |codename, card_id|
          check_duplicates hash, codename, card_id
          hash[codename] = card_id
          hash[card_id] = codename
        end
        hash
      end
    end
  end

  # If a card has the codename _example_, then Card::ExampleID should
  # return the id for that card. This method makes that help.
  #
  # @param const [Const]
  # @return [Integer]
  # @raise error if codename is missing
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
