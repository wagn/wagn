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
  #     :local_only                 Use only local cache for lookup and storing
  #     new: {  card opts }      Return a new card when not found
  #
  def fetch mark, opts = {}
    validate_fetch_opts! opts
    mark = normalize_mark mark

    if mark.present?
      card, mark, needs_caching = fetch_from_cache_or_db mark, opts
    else
      return unless opts[:new]
    end

    if mark.is_a?(Integer)
      return if card.nil?
    elsif card && card.new_card? && opts[:new].present?
      return card.renew(opts)
    elsif !card || (card.type_unknown? && !skip_type_lookup?(opts))
      needs_caching = true
      card = new_for_cache mark, opts # new (or improved) card for cache
    end

    write_to_cache card, opts if needs_caching

    if card.new_card?
      case
      when opts[:new].present? then return card.renew(opts)
      when opts[:new] # noop for empty hash
      when opts[:skip_virtual] then return nil
      end
      card.rename_from_mark mark unless opts[:local_only]
    end
    # need to load modules here to call the right virtual? method
    card.include_set_modules unless opts[:skip_modules]
    card if opts[:new] || card.known?
  end



  def fetch_local mark, opts = {}
    fetch mark, opts.merge(:local_only=>true)
  end

  def fetch_id mark
    if mark.is_a?(Integer)
      mark
    elsif mark.is_a?(Symbol) && Card::Codename[mark]
      Card::Codename[mark]
    else
      card = fetch mark.to_s, skip_virtual: true, skip_modules: true
      card && card.id
    end
  end

  def assign_or_initialize_by name, attributes, fetch_opts = {}
    if (known_card = Card.fetch(name, fetch_opts))
      known_card.refresh.assign_attributes attributes
      known_card
    else
      Card.new attributes.merge(name: name)
    end
  end

  def [] mark
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

  def expire name, subcards = false
    # note: calling instance method breaks on dirty names
    key = name.to_name.key
    if card = Card.cache.read(key)
      if subcards
        card.expire_subcards
      else
        card.preserve_subcards
      end
      Card.cache.delete key
      Card.cache.delete "~#{card.id}" if card.id
    end
    # Rails.logger.warn "expiring #{name}, #{card.inspect}"
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

  def validate_fetch_opts! opts
    if opts[:new] && opts[:skip_virtual]
      fail Card::Error, 'fetch called with new args and skip_virtual'
    end
  end

  def cache
    Card::Cache[Card]
  end

  def fetch_from_cache cache_key, local_only=false
    if Card.cache
      if local_only
        Card.cache.read_local cache_key
      else
        Card.cache.read cache_key
      end
    end
  end

  def fetch_from_cache_or_db mark, opts
    needs_caching = false
    mark_type = mark.is_a?(Integer) ? :id : :key
    expanded_mark = expand_mark mark, opts
    card = send("fetch_from_cache_by_#{mark_type}",
                expanded_mark, opts[:local_only])

    if card.nil? || (opts[:look_in_trash] && card.new_card? && !card.trash)
      query = { mark_type => expanded_mark }
      query[:trash] = false unless opts[:look_in_trash]
      card = fetch_from_db query
      needs_caching = card && !card.trash
      card.restore_subcards if card
    end

    [card, mark, needs_caching]
  end

  def fetch_from_cache_by_id id, local_only = false
    if name = fetch_from_cache("~#{id}", local_only)
      fetch_from_cache name, local_only
    end
  end

  def fetch_from_cache_by_key key, local_only = false
    fetch_from_cache key, local_only
  end

  def fetch_from_db query
    Card.where(query).take
  end

  def new_for_cache name, opts
    new name: name,
        skip_modules: true,
        skip_type_lookup: skip_type_lookup?(opts)
  end

  def skip_type_lookup? opts
    # if opts[:new] is not empty then we are initializing a variant that is
    # different from the cached variant
    # and can postpone type lookup for the cached variant
    # if skipping virtual no need to look for actual type
    opts[:skip_virtual] || opts[:new].present?
  end

  def write_to_cache card, opts
    if opts[:local_only]
      write_to_local_cache card
    elsif Card.cache
      Card.cache.write card.key, card
      Card.cache.write "~#{card.id}", card.key if card.id && card.id != 0
    end
  end

  def write_to_local_cache card
    if Card.cache
      Card.cache.write_local card.key, card
      Card.cache.write_local "~#{card.id}", card.key if card.id && card.id != 0
    end
  end

  def expand_mark mark, opts
    if mark.is_a?(Integer)
      mark
    else
      fullname_from_name(mark, opts[:new]).key
    end
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

  def fullname_from_name name, new_opts = {}
    if new_opts && supercard = new_opts[:supercard]
      name.to_name.to_absolute_name supercard.name
    else
      name.to_name
    end
  end
end

# ~~~~~~~~~~ Instance ~~~~~~~~~~~~~

def fetch opts = {}
  if traits = opts.delete(:trait)
    traits = Array.wrap traits
    traits.inject(self) do |card, trait|
      Card.fetch card.cardname.trait(trait), opts
    end
  end
end

def renew args = {}
  opts = args[:new].clone
  opts[:name] ||= cardname
  opts[:skip_modules] = args[:skip_modules]
  Card.new opts
end

def expire_pieces
  cardname.piece_names.each do |piece|
    Card.expire piece, true
  end
end

def expire subcards = false
  # Rails.logger.warn "expiring i:#{id}, #{inspect}"
  if subcards
    expire_subcards
  else
    preserve_subcards
  end
  Card.cache.delete key
  Card.cache.delete "~#{id}" if id
end

def refresh force = false
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

def type_unknown?
  type_id.nil?
end

def rename_from_mark mark
  return unless mark && mark.to_s != name
  self.name = mark.to_s
end

