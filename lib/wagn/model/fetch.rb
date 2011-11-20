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

    def fetch cardname, opts = {}
      cardname = cardname.to_cardname

      card = Card.cache.read( cardname.key )
      return nil if card && opts[:skip_virtual] && card.new_card?

      needs_caching = card.nil?
      card ||= find_by_key_and_trash( cardname.key, false )
      
      if card.nil?
        return nil if opts[:skip_virtual]
        card ||= new :name=>cardname, :skip_modules => true
      end

      Card.cache.write( cardname.key, card ) if needs_caching
      return nil if card.new_card? && !card.virtual?

      card.include_set_modules unless opts[:skip_modules]
      card
    end

    def fetch_or_new cardname, opts={}      
      fetch( cardname, opts ) || new( opts.merge(:name=>cardname) )
    end
    
    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( opts.merge(:name=>cardname) )
    end

    def exists?(cardname)
      fetch(cardname, :skip_virtual=>true, :skip_modules=>true).present?
    end
  end

  def refresh
    fresh_card = self.class.find(self.id)
    fresh_card.include_set_modules
    fresh_card
  end

  def self.included(base)
    super
    base.extend Wagn::Model::Fetch::ClassMethods
  end
end



