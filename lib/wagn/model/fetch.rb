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
    # if a card is not found in the database, a card of that name is created and added to cache with
    # missing? flag set to true
    # cards in the trash are added to the cache just as other cards are.  By default, missing? and trash?
    # cards are not returned
    def fetch cardname, opts = {}
      raise "??? no cardname #{cardname.inspect} #{opts.inspect}" unless cardname
      cardname = cardname.to_cardname unless Wagn::Cardname===cardname
      return nil unless cardname.valid_cardname?
      raise "??? cn  #{cardname.inspect} #{opts.inspect}" if cardname.to_s=~/^\//
      #warn "fetch #{cardname.inspect}"
      key = cardname.to_key

      card = Card.cache.read( key )
      return nil if card && opts[:skip_virtual] && card.missing?

      cacheable = card.nil?
      card ||= find_by_key_and_trash( key, false )
      
      Rails.logger.debug "fetch(#{cardname.inspect}) #{card.inspect}, #{cacheable}, #{opts.inspect}"# if debug
      Rails.logger.debug "fetch(#{cardname.inspect}) #{Kernel.caller*"\n"}" if cardname == 'a+y'

      card ||= new opts.merge(:name=>cardname, :missing=>true)
      Rails.logger.debug "fetch 2(#{cardname.to_s}) #{card.inspect}, #{opts.inspect}"# if debug

      Card.cache.write( key, card ) if cacheable
      Rails.logger.debug "fetch ret #{card.inspect}, #{opts.inspect}, #{card.missing? && (!card.virtual? || opts[:skip_virtual])}"
      return nil if card.missing? && (opts[:skip_virtual] || !card.virtual?)

      card.after_fetch 
      card
    end

    def fetch_or_new cardname, opts={}      
      fetch( cardname, opts ) || new( opts.merge(:name=>cardname, :missing=>true) )
    end
    
    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( opts.merge(:name=>cardname, :missing=>true) )
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
      attr_accessor :missing, :virtual
      alias :missing? :missing
      alias :virtual? :virtual
    }
  end
end



