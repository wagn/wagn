# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval
#


# TODO:
#  - implement Slot#cache_action  (for footer, etc.) if necessary
#

module Cardlib
  module Fetch
    mattr_accessor :cache
    mattr_accessor :debug
    self.debug = lambda {|x| false }
#    self.debug = lambda {|name| name.to_key == 'a' }

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
        debug = Cardlib::Fetch.debug.call(cardname)
        Rails.logger.debug "fetch #{cardname}"  if debug
        key = cardname.to_key
        cacheable = false

        card = Card.builtin_virtual( cardname ) unless opts[:skip_virtual]
        Rails.logger.debug "   builtin_virtual: #{card.inspect}" if card && debug

        if perform_caching?
          card ||= Card.cache.read( key )
          cacheable = true if card.nil?
          Rails.logger.debug "   cache.read: #{card.inspect}" if debug
        end

        card ||= begin
          Rails.logger.debug "   find_by_key: #{card.inspect}" if debug
          Card.find_by_key( key )
        end

        if !opts[:skip_virtual] && (!card || card.missing? || card.trash? || card.builtin?)
          if virtual_card = Card.pattern_virtual( cardname )
            card = virtual_card
            Rails.logger.debug "   pattern_virtual: #{card.inspect}" if debug
            card.missing = true
          end
        end
        card ||= begin
           Rails.logger.debug "   new(missing): #{card.inspect}" if debug
           new_missing cardname
        end



        if cacheable
          Card.cache.write key, card
          Rails.logger.debug "   writing: #{card.inspect}" if debug
        end

        if (card.missing? && !card.virtual?) || card.trash?
          Rails.logger.debug "   final: missing (nil)"  if debug
          return nil
        end
        Rails.logger.debug "   final: #{card.inspect}"  if debug
        card
      end

      def fetch_or_new cardname, fetch_opts = {}, card_opts = {}
        card_opts[:name] = cardname
        fetch( cardname, fetch_opts ) || Card.new( card_opts )
      end
      
      def fetch_or_create cardname, fetch_opts = {}, card_opts = {}
        card_opts[:name] = cardname
        fetch_opts[:skip_virtual] ||= true
        fetch( cardname, fetch_opts ) || Card.create( card_opts )
      end

      def preload cards, opts = {}
        cards.each do |card|
          if opts[:local]
            Card.cache.write_local(card.key, card)
          else
            Card.cache.write(card.key, card)
          end
        end
      end

      def new_missing cardname
        Card.new( :name => cardname, :skip_defaults    => true,
                   :missing => true,  :skip_type_lookup => true )
      end

      def exists?(name)
        fetch(name, :skip_virtual=>true).present?
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


