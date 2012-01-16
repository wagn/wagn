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
#      ActiveSupport::Notifications.instrument 'wagn.fetch', :message=>"fetch #{cardname}" do
      
        card_from_id = card_id = nil
        if Integer===cardname
          card_id = cardname
          if card_from_id = Card.id_cache[card_id]
            return card_from_id
          elsif card_from_id = Card.find_by_id_and_trash(card_id, false)
            cardname = card_from_id.cardname
          else raise "fetch of missing card_id #{cardname}"
          end
        else
          cardname = cardname.to_cardname
        end

        card = Card.cache.read( cardname.key ) if Card.cache
        return nil if card && opts[:skip_virtual] && card.new_card?

        needs_caching = !Card.cache.nil? && card.nil?
        card ||= card_from_id
        card ||= find_by_key_and_trash( cardname.key, false )
      
        if card.nil? || (!opts[:skip_virtual] && card.type_id==0)
          # The 0 type_id allows us to skip all the type lookup and flag the need for reinitialization later
          needs_caching = !Card.cache.nil?
          card = new((opts[:skip_virtual] ? {:type_id=>0} : {}).merge(:name=>cardname, :skip_modules=>true))
        end
      
        if needs_caching
          Card.id_cache[card_id]= card if card_id
          Card.cache.write( cardname.key, card )
        end
        return nil if card.new_card? && (opts[:skip_virtual] || !card.virtual?)

        card.include_set_modules unless opts[:skip_modules]
        card
#      end
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
    
    def autoname(name)
      exists?(name) ? autoname(name.next) : name
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



