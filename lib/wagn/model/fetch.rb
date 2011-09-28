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
      cacheable = false

      card = Card.cache.read( key )
      return nil if card && opts[:skip_virtual] && card.missing?

      cacheable = true if card.nil?
      card ||= find_by_key_and_trash( key, false )
      
      Rails.logger.debug "fetch(#{cardname.inspect}) #{card.inspect}, #{cacheable}, #{opts.inspect}"# if debug
      Rails.logger.debug "fetch(#{cardname.inspect}) #{Kernel.caller*"\n"}" if cardname == 'Pointer+*type'
      if !opts[:skip_virtual] && (!card || card.missing?)
        card = fetch_virtual( cardname, card )
        Rails.logger.info "fetch_virtual #{card.inspect}"
      end
      
      #return nil if !card
      if card.nil?
        new_opts = {:name=>cardname, :missing=>true}
        new_opts.merge!(:missing=>:unreal, :skip_type_lookup=>true) if opts[:skip_virtual] 
        card = new opts.merge(new_opts)
      end

      Card.cache.write( key, card ) #if cacheable
=begin
      unless opts[:skip_virtual]
        if cacheable && !opts[:skip_virtual]
          Card.cache.write( key, card )
        else Card.cache.write_local( key, card ) end
      end
=end
      Rails.logger.debug "fetch ret #{card.inspect} #{!card.virtual? || opts[:skip_virtual]}"
      return nil if (card.missing? && (!card.virtual? || opts[:skip_virtual]))

      card.after_fetch #unless opts[:skip_after_fetch]
      #card.after_fetch unless opts[:skip_after_fetch] || (opts[:skip_virtual] && card.missing?)
      card
    end

    def fetch_or_new cardname, opts={}
      
      fetch( cardname, opts ) || new( opts.merge(:name=>cardname, :missing=>true) )
    end
    
    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( opts.merge(:name=>cardname, :missing=>true) )
    end
    
=begin
    def extract_new_opts cardname, opts
      opts = opts.clone
      opts[:name] = cardname
      [:skip_virtual, :skip_after_fetch].each {|key| opts.delete(key)}
      opts
    end
=end
    
    def fetch_virtual(cardname, cached_card=nil)
      #cardname = name.to_cardname
      return nil unless cardname && cardname.junction?
      cached_card = nil if cached_card && cached_card.trash
      test_card = cached_card || Card.new(:name=>cardname, :missing=>true )
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
      new(:name=>cardname, :content=>content, :typecode=>type, :missing=>true, :virtual=>true)
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



