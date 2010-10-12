# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval
#
module Cardlib
  module Fetch
    mattr_accessor :cache

    module ClassMethods
      def perform_caching?
        true
      end

      # === fetch
      #
      # looks for cards in
      #   - cache
      #   - builtin cards
      #   - virtual cards
      #   - database
      #
      # if a card is not in the cache and is found in the database, it is added to the cache
      # if a card is not found in the database, a card of that name is created and added to cache with
      # missing? flag set to true
      # cards in the trash are added to the cache just as other cards are.  By default, missing? and trash?
      # cards are not returned
      def fetch cardname, opts = {}
        key = cardname.to_key

        if perform_caching?
          card = Card.cache.read( key )
          wasnt_cached = true if card.nil?
        end
        card = Card.find_builtin( key ) unless card || opts[:skip_auto]
        card = Card.find_virtual( key ) unless card || opts[:skip_auto]
        card = Card.find_by_key( key )  unless card
        card = Card.new( :name => cardname, :missing => true ) unless card

        if wasnt_cached and !card.builtin? and !card.virtual?
          Card.cache.write key, card
        end

        if card.missing? or card.trash?
          return nil
        end

        card
      end

      def fetch_or_new cardname, *args
        opts = args.extract_options!
        opts[:name] ||= cardname
        fetch( cardname ) or Card.new( opts )
      end

      def fetch_real cardname, opts={}
        opts[:skip_auto] = true
        fetch cardname, opts
      end
    end

    module InstanceMethods
      def missing?
        @missing
      end
    end
  end
end

Card.extend Cardlib::Fetch::ClassMethods
Card::Base.class_eval do
  include Cardlib::Fetch::InstanceMethods
  attr_accessor :missing
end


