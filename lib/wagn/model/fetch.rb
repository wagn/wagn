# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval
#


# TODO:
#  - implement Renderer#cache_action  (for footer, etc.) if necessary
#

module Wagn::Model::Fetch
  mattr_accessor :cache
  mattr_accessor :debug
  self.debug = false #lambda {|x| false }
  #self.debug = lambda {|name| name.to_key == 'a+y' }

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
      #debug = Card::Fetch.debug.call(cardname)
      Rails.logger.debug "fetch #{cardname.inspect} \nTrace #{Kernel.caller[0..10]*"\n"}" unless String===cardname # if debug
      key = cardname.to_key
      cacheable = false

      if perform_caching?
        card ||= Card.cache.read( key )
        cacheable = true if card.nil?
        Rails.logger.debug "   cache.read: #{card.inspect}" if debug
      end

      card ||= begin
        Rails.logger.debug "   find_by_key: #{key.inspect}" #if debug
        #Card.find_by_key_and_trash( key , false )
        Card.find_by_key( key )
      end
              
      if !opts[:skip_virtual] && (!card || card.missing? || card.trash)
        if virtual_card = Card.pattern_virtual( cardname, card )
          card = virtual_card
          Rails.logger.debug "   pattern_virtual: #{card.inspect}" if debug
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

      if (card.missing? && (!card.virtual? || opts[:skip_virtual])) || card.trash
        Rails.logger.debug "   final: missing (nil)"  if debug
        return nil
      end
      card.after_fetch unless opts[:skip_after_fetch]
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
      Card.new(:name=>cardname, :typecode=>'Basic', :skip_defaults=>true, :missing=>true)
    end

    def exists?(name)
      fetch(name, :skip_virtual=>true).present?
    end

  end

  def self.included(base)
    super
    #Rails.logger.info "included(#{base}) S:#{self}"
    base.extend Wagn::Model::Fetch::ClassMethods
    base.class_eval {
      attr_accessor :missing
      alias :missing? :missing
    }
  end
end



