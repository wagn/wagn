# = Card#fetch
#
# A multipurpose retrieval operator that incorporates caching, "virtual" card retrieval

module ClassMethods

  # === fetch
  #
  # looks for cards in
  #   - cache
  #   - database
  #   - virtual cards
  #
  # "mark" here means one of three unique identifiers
  #    1. a numeric id (Integer)
  #    2. a name/key (String or Card::Name)
  #    3. a codename (Symbol)
  #
  #   Options:
  #     :skip_virtual               Real cards only
  #     :skip_modules               Don't load Set modules
  #     :look_in_trash              Return trashed card objects
  #     new: {  card opts }      Return a new card when not found
  #
  def fetch mark, opts={}
    mark = normalize_mark mark

    if mark.present?
      card, mark, needs_caching = fetch_from_cache_or_db mark, opts # have existing
    else
      return unless opts[:new]
    end

    if Integer===mark
      return if card.nil? || mark.nil?
    else
      return card.renew(opts) if card and card.eager_renew?(opts)
      if !card or card.type_id==-1 && clean_cache_opts?(opts)       # new (or improved) card for cache
        needs_caching = true
        card = new_for_cache mark, opts
      end
    end

    write_to_cache card if Card.cache && needs_caching

    if card.new_card?
      if opts[:new]
        return card.renew(opts) if !clean_cache_opts? opts
      elsif opts[:skip_virtual]
        return
      else
        card.include_set_modules unless opts[:skip_modules]  # need to load modules here to call the right virtual? method
        return unless card.virtual? || opts[:subcard]
      end
      card.name = mark.to_s if mark && mark.to_s != card.name && !opts[:subcard]
    end

    card.include_set_modules unless opts[:skip_modules]
    card
  end

  def normalize_mark mark
    case mark
    when String
      case mark
      when /^\~(\d+)$/ # get by id
        $1.to_i
      when /^\:(\w+)$/ # get by codename
        Card::Codename[$1.to_sym]
      else
        mark
      end
    when Symbol
      Card::Codename[mark] # id from codename
    else
      mark
    end
  end

  def fetch_id mark #should optimize this.  what if mark is int?  or codename?
    card = fetch mark, skip_virtual: true, skip_modules: true
    card and card.id
  end

  def assign_or_initialize_by name, attributes
    if known_card = Card.fetch(name, :subcard=>true)
      known_card.refresh.assign_attributes attributes
      known_card
    else
      Card.new attributes.merge(:name => name)
    end
  end

  def [](mark)
    fetch mark, skip_virtual: true
  end

  def exists? mark
    card = fetch mark, skip_virtual: true, skip_modules: true
    card.present?
  end

  def known? mark
    card = fetch mark, skip_modules: true
    card.present?
  end

  def expire name, subcards=false
    #note: calling instance method breaks on dirty names
    key = name.to_name.key
    if card = Card.cache.read( key )
      if subcards
        card.expire_subcards
      else
        card.preserve_subcards
      end
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

  def cache
    Card::Cache[Card]
  end

  def fetch_from_cache cache_key
    Card.cache.read cache_key if Card.cache
  end

  def fullname_from_name name, new_opts={}
    if new_opts and supercard = new_opts[:supercard]
      name.to_name.to_absolute_name supercard.name
    else
      name.to_name
    end
  end

  def fetch_from_cache_or_db mark, opts
    needs_caching = false
    mark_type = Integer===mark ? :id : :key

    if mark_type == :key
      mark = fullname_from_name mark, opts[:new]
      val = mark.key
    else
      val = mark
    end

    card = send( "fetch_from_cache_by_#{mark_type}", val )

    if card.nil? || ( opts[:look_in_trash] && card.new_card? && !card.trash )
      query = { mark_type => val }
      query[:trash] = false unless opts[:look_in_trash]
      card = fetch_from_db query
      needs_caching = card && !card.trash
      card.restore_subcards if card
    end


    [ card, mark, needs_caching ]
  end


  def fetch_from_cache_by_id id
    if name = fetch_from_cache("~#{id}")
      fetch_from_cache name
    end
  end

  def fetch_from_cache_by_key key
    fetch_from_cache key
  end

  def fetch_from_db query
    Card.where(query).take
  end

  def new_for_cache name, opts
    new_args = { name: name, skip_modules: true }
    new_args[:type_id] = -1 unless clean_cache_opts? opts
    # The -1 type_id allows us to skip all the type lookup and flag the need for
    # reinitialization later.  *** It should NEVER be seen elsewhere ***
    new new_args
  end

  def clean_cache_opts? opts
    !opts[:skip_virtual] && !opts[:new].present?
  end

  def write_to_cache card
    Card.cache.write card.key, card
    Card.cache.write "~#{card.id}", card.key if card.id and card.id != 0
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
  opts = args[:new].clone
  opts[:name] ||= cardname
  opts[:skip_modules] = args[:skip_modules]
  Card.new opts
end

def expire_pieces
  cardname.piece_names.each do |piece|
    Card.expire piece
  end
end


def expire subcards=false
  #Rails.logger.warn "expiring i:#{id}, #{inspect}"
  if subcards
    expire_subcards
  else
    preserve_subcards
  end
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

def eager_renew? opts
  opts[:skip_virtual] && new_card? && opts[:new].present?
end


