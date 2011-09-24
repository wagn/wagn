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
      cardname = cardname.to_cardname unless Wagn::Cardname==cardname
      key = cardname.to_key
      cacheable = false

      card = Card.cache.read( key )
      cacheable = true if card.nil?
      card ||= find_by_key( key )
      
      #Rails.logger.debug "fetch(#{cardname.inspect}) #{card.inspect}, #{cacheable}, #{opts.inspect}"# if debug
      if !opts[:skip_virtual] && (!card || card.missing? || card.trash)
        card = fetch_virtual( cardname, card )
        #Rails.logger.info "fetch_virtual #{card.inspect}"
      end
      
      return nil if !card
      #card ||= new_missing cardname
      Card.cache.write( key, card ) if cacheable
      return nil if (card.missing? && (!card.virtual? || opts[:skip_virtual])) || card.trash

      cardname.card = card unless cardname.card_without_fetch
      card.after_fetch unless opts[:skip_after_fetch]
      card
    end
    def fetch_with_cardname cardname, opts = {}
      cardname = cardname.to_cardname unless Wagn::Cardname==cardname
      return card if card = cardname.card_without_fetch
      fetch_without_cardname cardname, opts
    end
    alias_method_chain :fetch, :cardname

    def fetch_or_new cardname, opts={}
      fetch( cardname, opts ) || new( extract_new_opts(cardname, opts) )
    end
    
    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( extract_new_opts(cardname, opts) )
    end
    
    def extract_new_opts cardname, opts
      opts = opts.clone
      opts[:name] = cardname
      [:skip_virtual, :skip_after_fetch].each {|key| opts.delete(key)}
      opts
    end
    
    def fetch_virtual(cardname, cached_card=nil)
      #cardname = name.to_cardname
      return nil unless cardname && cardname.junction?
      cached_card = nil if cached_card && cached_card.trash
      test_card = cached_card || Card.new(:name=>cardname, :missing=>true, :typecode=>'Basic', :skip_defaults=>true)
       template=test_card.template(reset=true) and ht=template.hard_template? 
      #Rails.logger.debug "fetch_virtual(#{cardname.to_s}) #{test_card.name}, #{cardname.tag_name} >#{template}, #{ht}"
      if ht
      #if template=test_card.template(reset=true) and template.hard_template? 
        args=[cardname, template.content, template.typecode]
        #Rails.logger.debug "fetch_virtual(#{cardname.to_s}) #{args.inspect}"
        if cached_card
          cached_attrs = [:cardname, :content, :typecode].map{|attr| cached_card.send(attr)}
        #Rails.logger.debug "fetch_virtual(#{cardname.to_s})cached: #{cached_attrs.inspect}"
          return cached_card if args==cached_attrs
        end
        r=new_virtual cardname, template.content, template.typecode
        #Rails.logger.debug "fetch_virtual(#{cardname.to_s}) new_v#{r.inspect}"; r
      elsif System.ok?(:administrate_users) and cardname.tag_name == '*email'
        return nil if ( content =
                retrieve_extension_attribute(cardname.trunk_name, 'email') ).blank?

        r=new_virtual cardname, content  
      #Rails.logger.debug "fetch_virtual adm-email(#{cardname.to_s}) email, #{content.inspect}, #{r.inspect}"; r
      else
        #Rails.logger.debug "fetch_virtual(#{cardname.to_s}) nill"
        return nil
      end
    end

    def retrieve_extension_attribute( name, attr_name )
      c = fetch(name.to_cardname) and e=c.extension and e.send(attr_name)
    end

    def new_virtual(cardname, content, type='Basic')
      new(:name=>cardname, :content=>content, :typecode=>type, :missing=>true, :virtual=>true, :skip_defaults=>true)
    end

    def new_missing cardname
      new(:name=>cardname, :typecode=>'Basic', :skip_defaults=>true, :missing=>true)
    end

    def exists?(cardname)
      fetch(cardname, :skip_virtual=>true, :skip_after_fetch=>true).present?
    end
  end


  def after_fetch
#    warn "after_fetch cardname: #{cardname.s}"
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



