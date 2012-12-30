# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval


module Cardlib::Fetch
  mattr_accessor :cache

  module ClassMethods

    # === fetch
    #
    # looks for cards in
    #   - cache
    #   - database
    #   - virtual cards
    #
    #   Options:
    #     :skip_vitual                Real cards only
    #     :skip_modules               Don't load Set modules
    #     :loaded_trunk => card       Loads the card's trunk
    #     :new => {  card opts }      Return a new card when not found
    #     :trait => :code (or [:c1, :c2] maybe?)  Fetches base card + tag(s)
    #

    def fetch mark, opts = {}
      # "mark" here means a generic identifier -- can be a numeric id, a name, a string name, etc.
#      ActiveSupport::Notifications.instrument 'wagn.fetch', :message=>"fetch #{cardname}" do
      if mark.nil?
        return if opts[:new].nil?
        # This is fetch_or_new now when you supply :new=>{opts}

      else

        #warn "fetch #{mark.inspect}, #{opts.inspect}"
        # Symbol (codename) handling
        if Symbol===mark
          mark = Wagn::Codename[mark] || raise("Missing codename for #{mark.inspect}")
        end


        cache_key, method, val = if Integer===mark
          [ "~#{mark}", :find_by_id_and_trash, mark ]
        else
          key = mark.to_name.key
          [ key, :find_by_key_and_trash, key ]
        end

        #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        # lookup card

        #Cache lookup
        result = Card.cache.read cache_key if Card.cache
        card = (result && Integer===mark) ? Card.cache.read(result) : result
        #warn "fetch R #{cache_key}, #{method}, R:#{result}, c:#{card&&card.name}"

        unless card
          # DB lookup
          needs_caching = true
          card = Card.send method, val, false
        end
      end

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      opts[:skip_virtual] = true if opts[:loaded_trunk]

      if Integer===mark
        raise "fetch of missing card_id #{mark}" if card.nil?
      else
        return card.fetch_new(opts) if card && opts[:skip_virtual] && card.new_card?

        # NEW card -- (either virtual or missing)
        if card.nil? or ( !opts[:skip_virtual] && card.type_id==-1 )
          # The -1 type_id allows us to skip all the type lookup and flag the need for
          # reinitialization later.  *** It should NEVER be seen elsewhere ***
          needs_caching = true
          new_args = { :name=>mark.to_s, :skip_modules=>true }
          new_args[:type_id] = -1 if opts[:skip_virtual]
          card = new new_args
        end
      end

      if Card.cache && needs_caching
        Card.cache.write card.key, card
        Card.cache.write "~#{card.id}", card.key if card.id and card.id != 0
      end

      return card.fetch_new(opts) if card.new_card? and ( opts[:skip_virtual] || !card.virtual? )

      #warn "fetch returning #{card.inspect}"
      card.include_set_modules unless opts[:skip_modules]
      card
    end

    def fetch_or_new cardname, opts={}
      fetch cardname, opts or new opts.merge(:name=>cardname)
    end

    def fetch_or_create cardname, opts={}
      opts[:skip_virtual] ||= true
      fetch( cardname, opts ) || create( opts.merge(:name=>cardname) )
    end

    def fetch_id mark #should optimize this.  what if mark is int?  or codename?
      card = fetch mark, :skip_virtual=>true, :skip_modules=>true
      card and card.id
    end

    def [](name)
      fetch name, :skip_virtual=>true
    end

    def exists? cardname
      card = fetch cardname, :skip_virtual=>true, :skip_modules=>true
      card.present?
    end

    def expire name
      if card = Card.cache.read( name.to_name.key )
        card.expire
      end
    end

    # set_names reverse map (cached)
    def members key
      (v=Card.cache.read "$#{key}").nil? ? [] : v.keys
    end

    def set_members set_names, key

      #warn Rails.logger.warn("set_members #{set_names.inspect}, #{key}")
      set_names.compact.map(&:to_name).map(&:key).map do |set_key|
        skey = "$#{set_key}" # dollar sign avoids conflict with card keys
        h = Card.cache.read skey
        if h.nil?
          h = {}
        elsif h[key]
          next
        end
        h = h.dup if h.frozen?
        h[key] = true
        #warn Rails.logger.warn("set_members w #{h.inspect}, #{skey.inspect}")
        Card.cache.write skey, h
      end
    end

  end

  # ~~~~~~~~~~ Instance ~~~~~~~~~~~~~
  
  def fetch opts={}
    if traits = opts.delete(:trait)
       traits = [traits] unless Array===traits
       traits.inject(self) { |card, trait| Card.fetch( card.cardname.trait(trait), opts ) }
    end
  end

  def fetch_new opts={}
    opts = opts[:new] and Card.new opts.merge(:name=>cardname)
  end

  def expire_pieces
    cardname.piece_names.each do |piece|
      Card.expire piece
    end
  end

  def expire_related
    self.expire

    if self.hard_template?
      self.hard_templatee_names.each do |name|
        Card.expire name
      end
    end
    # FIXME really shouldn't be instantiating all the following bastards.  Just need the key.
    # fix in id_cache branch
    self.dependents.each       { |c| c.expire }
    self.referencers.each      { |c| c.expire }
    self.name_referencers.each { |c| c.expire }
    # FIXME: this will need review when we do the new defaults/templating system
    #if card.changed?(:content)
  end

  def expire
    Card.cache.delete key
    Card.cache.delete "~#{id}" if id
  end

  def refresh
    if self.frozen? || self.readonly?
      fresh_card = self.class.find id
      fresh_card.include_set_modules
      fresh_card
    else
      self
    end
  end

  def self.included(base)
    super
    base.extend Cardlib::Fetch::ClassMethods
  end
end



