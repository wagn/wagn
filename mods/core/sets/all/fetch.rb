# -*- encoding : utf-8 -*-
# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval

module ClassMethods
  
  def cache
    Wagn::Cache[Card]
  end

  # === fetch
  #
  # looks for cards in
  #   - cache
  #   - database
  #   - virtual cards
  #
  # "mark" here means a generic identifier -- can be a numeric id, a name, a string name, etc.
  #
  #   Options:
  #     :skip_virtual               Real cards only
  #     :skip_modules               Don't load Set modules
  #     :new => {  card opts }      Return a new card when not found
  #

  def fetch mark, opts = {}
#      ActiveSupport::Notifications.instrument 'wagn.fetch', :message=>"fetch #{mark}" do

    if mark.nil?
      return if opts[:new].nil?
    else

      if Symbol===mark
        mark = Card::Codename[mark] || raise( "Missing codename for #{mark.inspect}" )
      end

      cache_key, method, val = if Integer===mark
        [ "~#{mark}", :find_by_id_and_trash, mark ]
      else
        opts[:name] = mark # this is needed to correctly fetch missing cards with different name variants in cache
        key = mark.to_name.key
        [ key, :find_by_key_and_trash, key ]
      end

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # lookup card

      #Cache lookup
      result = Card.cache.read cache_key if Card.cache
      card = (result && Integer===mark) ? Card.cache.read(result) : result

      unless card
        # DB lookup
        needs_caching = true
        card = Card.send method, val, false
      end
    end

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if Integer===mark
      if card.nil?
        Rails.logger.info "fetch of missing card_id #{mark}" # should send this to airbrake
        return nil
      end
    else
      if card && opts[:skip_virtual] && card.new_card? && opts[:new] != {}
        return card.renew(opts)
      end

      # NEW card -- (either virtual or missing)
      if card.nil? or ( card.type_id==-1 && ( !opts[:skip_virtual] || opts[:new]=={} ) )
        # The -1 type_id allows us to skip all the type lookup and flag the need for
        # reinitialization later.  *** It should NEVER be seen elsewhere ***
        needs_caching = true
        new_args = { :name=>mark.to_s, :skip_modules=>true }
        new_args[:type_id] = -1 if opts[:skip_virtual] && opts[:new] != {}
        card = new new_args
      end
    end

    begin
      if Card.cache && needs_caching
        Card.cache.write card.key, card
        Card.cache.write "~#{card.id}", card.key if card.id and card.id != 0
      end
    rescue TypeError
      # I believe this only happens in development
      Rails.logger.info "TypeError rescued"
    end

    if card.new_card?
      if opts[:new] == {}
        #noop default case; use cache.
      elsif !opts[:new].blank? || opts[:skip_virtual] || !card.virtual?
        return card.renew(opts)
      end
      
      if opts[:name] && opts[:name] != card.name
        card.name = opts[:name]
      end
    end

    card.include_set_modules unless opts[:skip_modules]
    card
  end

  def fetch_id mark #should optimize this.  what if mark is int?  or codename?
    card = fetch mark, :skip_virtual=>true, :skip_modules=>true
    card and card.id
  end

  def [](name)
    fetch name, :skip_virtual=>true
  end

  def exists? name
    card = fetch name, :skip_virtual=>true, :skip_modules=>true
    card.present?
  end

  def expire name
    #note: calling instance method breaks on dirty names
    key = name.to_name.key
    if card = Card.cache.read( key ) 
      Card.cache.delete key
      Card.cache.delete "~#{card.id}" if card.id
    end
    #Rails.logger.warn "expiring #{name}, #{card.inspect}"
  end

  # set_names reverse map (cached)
  def members key
    (v=Card.cache.read "$#{key}").nil? ? [] : v.keys
  end

  def set_members set_names, key
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

def renew args={}
  if opts = args[:new]
    opts[:name] ||= cardname
    opts[:skip_modules] = args[:skip_modules]
    Card.new opts
  end
end

def expire_pieces
  cardname.piece_names.each do |piece|
    Card.expire piece
  end
end


def expire
  #Rails.logger.warn "expiring i:#{id}, #{inspect}"
  Card.cache.delete key
  Card.cache.delete "~#{id}" if id
end

def refresh force=false
  if force || self.frozen? || self.readonly?
    fresh_card = self.class.find id
    fresh_card.include_set_modules
    fresh_card
  else
    self
  end
end
