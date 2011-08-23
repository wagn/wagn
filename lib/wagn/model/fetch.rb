# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval


module Wagn::Model::Fetch
  mattr_accessor :cache
  mattr_accessor :debug
  self.debug = false #lambda {|x| false }
  #self.debug = lambda {|name| name.to_key == 'a+y' }

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
      key = cardname.to_key
      cacheable = false

      card = Card.cache.read( key )
      cacheable = true if card.nil?
      card ||= find_by_key( key )
      
      if !opts[:skip_virtual] && (!card || card.missing? || card.trash)
        card = fetch_virtual( cardname, card )
      end
      
      card ||= new_missing cardname
      Card.cache.write( key, card ) if cacheable
      return nil if (card.missing? && (!card.virtual? || opts[:skip_virtual])) || card.trash

      card.after_fetch unless opts[:skip_after_fetch]
      card
    end

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
    
    def fetch_virtual(name, cached_card=nil)
      return nil unless name && name.junction?
      cached_card = nil if cached_card && cached_card.trash
      test_card = cached_card || Card.new(:name=>name, :missing=>true, :typecode=>'Basic', :skip_defaults=>true)
      if template=test_card.template(reset=true) and template.hard_template? 
        args=[name, template.content, template.typecode]
        if cached_card
          cached_attrs = [:name, :content, :typecode].map{|attr| cached_card.send(attr)}
          return cached_card if args==cached_attrs
        end
        new_virtual name, template.content, template.typecode
      elsif System.ok?(:administrate_users) and name.tag_name =~ /^\*(email)$/
        attr_name = $~[1]
        content = retrieve_extension_attribute( name.trunk_name, attr_name ) || ""
        new_virtual name, content  
      else
        return nil
      end
    end

    def retrieve_extension_attribute( cardname, attr_name )
      c = fetch(cardname) and e=c.extension and e.send(attr_name)
    end

    def new_virtual(name, content, type='Basic')
      new(:name=>name, :content=>content, :typecode=>type, :missing=>true, :virtual=>true, :skip_defaults=>true)
    end

    def new_missing cardname
      new(:name=>cardname, :typecode=>'Basic', :skip_defaults=>true, :missing=>true)
    end

    def exists?(name)
      fetch(name, :skip_virtual=>true).present?
    end
  end


  def after_fetch
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



