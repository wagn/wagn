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

    def fetch mark, opts = {}
#      ActiveSupport::Notifications.instrument 'wagn.fetch', :message=>"fetch #{cardname}" do
      opts[:skip_virtual] = true if opts[:loaded_trunk]
      card = cardname = nil
      
      if Integer===mark
        card_id = mark
        card = Card.id_cache[ card_id ]
        unless card
          needs_caching = true
          card = Card.find_by_id_and_trash card_id, false
          raise "fetch of missing card_id #{card_id}" unless card
        end
      else
        cardname = mark.to_cardname
        card = Card.cache.read( cardname.key ) if Card.cache
        return nil if card && opts[:skip_virtual] && card.new_card?
        
        unless card
          needs_caching = true
          card = find_by_key_and_trash cardname.key, false
        end
        
        if card.nil? || (!opts[:skip_virtual] && card.type_id==0)
          needs_caching = true
          new_args = { :name=>cardname.to_s, :skip_modules=>true }
          new_args[:type_id] = 0 if opts[:skip_virtual]
          card = new new_args
        end
      end
      
    
      if Card.cache && needs_caching
        Card.id_cache[ card.id ] = card
        Card.cache.write card.key, card
      end
      
      return nil if card.new_card? and opts[:skip_virtual] || !card.virtual?

      #warn "fetch returning #{card.inspect}"
      card.include_set_modules unless opts[:skip_modules]
      card
#      end
    end

    def fetch_or_new cardname, opts={}
      #warn "fetch_or_new #{cardname.inspect}, #{opts.inspect}"
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



