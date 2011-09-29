# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval


module Wagn::Model::Fetch
  mattr_accessor :cache
  mattr_accessor :debug
  #self.debug = false #lambda {|x| false }
  self.debug = lambda {|name| name.to_key == '*all+*create' }

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
      
#      Rails.logger.debug "fetch(#{cardname.inspect}) #{card.inspect}, #{cacheable}, #{opts.inspect}"# if debug
#      Rails.logger.debug "fetch(#{cardname.inspect}) #{Kernel.caller*"\n"}" if cardname == 'a+y'


      Card.cache.write( key, card ) if cacheable
#      Rails.logger.debug "fetch ret #{card.inspect}, #{opts.inspect}, #{card.new_card? && (!card.virtual? || opts[:skip_virtual])}"
      return nil if card.new_card? && (opts[:skip_virtual] || !card.virtual?)

      card.after_fetch 
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
      fetch(cardname, :skip_virtual=>true).present?
    end
  end


  def after_fetch
    Rails.logger.warn "after_fetch cardname: #{cardname.s}"
    include_set_modules
  end


  def self.included(base)
    super
    #Rails.logger.info "included(#{base}) S:#{self}"
    base.extend Wagn::Model::Fetch::ClassMethods
    base.class_eval {
      attr_accessor :virtual
      alias :virtual? :virtual
    }
  end
end



