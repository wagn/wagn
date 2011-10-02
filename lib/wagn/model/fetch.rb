# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval


module Wagn::Model::Fetch
  mattr_accessor :cache

  module ClassMethods

    # === fetch
    #
    # looks for cards in
    #   - cache
    #   - database
    #   - virtual cards
    #
    # if a card is not in the cache and is found in the database, it is added to the cache
    # if a card is not found in the database, a card of that name is created and added to cache

    def fetch cardname, opts = {}
      #warn "fetching #{cardname}"
      cardname = cardname.to_cardname unless Wagn::Cardname===cardname
      return nil unless cardname.valid_cardname?
      key = cardname.to_key

      card = Card.cache.read( key )

      return nil if card && opts[:skip_virtual] && card.new_card?

      cacheable = card.nil?
      card ||= find_by_key_and_trash( key, false )
      card ||= new :name=>cardname, :skip_type_lookup=>opts[:skip_virtual]


      Card.cache.write( key, card ) if cacheable
      #warn "fetch ret #{card.inspect}, #{opts.inspect}, #{card.new_card? && (!card.virtual? || opts[:skip_virtual])}" if key == 'pointer+*type'
      return nil if card.new_card? && (opts[:skip_virtual] || !card.virtual?)

      card
    end

    def fetch_or_new cardname, opts={}
      fetch( cardname, opts ) || new( opts.merge(:name=>cardname) )
    end

    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( opts.merge(:name=>cardname) )
    end

    def exists?(cardname) self[cardname].present?  end
  end


  def self.included(base)
    super
    base.extend Wagn::Model::Fetch::ClassMethods
  end
end



