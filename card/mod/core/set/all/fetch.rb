# = Card#fetch
#
# A multipurpose retrieval operator that integrates caching, database lookups,
# and "virtual" card construction
module ClassMethods
  # === fetch
  #
  # looks for cards in
  #   - cache
  #   - database
  #   - virtual cards
  #
  # @param [Integer, String, Card::Name, Symbol] mark one of three unique
  #   identifiers
  #    1. a numeric id (Integer)
  #    2. a name/key (String or Card::Name)
  #    3. a codename (Symbol)
  #   or any combination of those. If you pass more then one mark they get
  #   joined with a '+'
  # @param [Hash] opts ({})
  #   Options:
  #     :skip_virtual               Real cards only
  #     :skip_modules               Don't load Set modules
  #     :look_in_trash              Return trashed card objects
  #     :local_only                 Use only local cache for lookup and storing
  #     new: {  card opts }      Return a new card when not found
  #
  def fetch *args
    mark, opts = normalize_fetch_args args
    validate_fetch_opts! opts
    card, needs_caching = fetch_existing mark, opts

    if (new_card = new_for_cache card, mark, opts)
      card = new_card
      needs_caching = true
    end

    return if card.nil?
    write_to_cache card, opts if needs_caching
    standard_fetch_results card, mark, opts
  end

  # #fetch converts String to Card::Name. That can break in some cases.
  # For example if you fetch "Siemens" by its key "siemen", you won't get
  # "Siemens" because "siemen".to_name.key == "sieman"
  # If you have a key of a real card use this method.
  def fetch_real_by_key key, opts={}
    raise Card::Error, "fetch_real_by_key called with new args" if opts[:new]

    # look in cache
    card = fetch_from_cache_by_key key, opts[:local_only]
    # look in db if needed
    if retrieve_from_db?(card, opts)
      card = fetch_from_db :key, key, opts
      write_to_cache card, opts if !card.nil? && !card.trash
    end
    return if card.nil?
    card.include_set_modules unless opts[:skip_modules]
    card
  end

  def standard_fetch_results card, mark, opts
    if card.new_card?
      case
      when opts[:new].present? then return card.renew(opts)
      when opts[:new] # noop for empty hash
      when opts[:skip_virtual] then return nil
      end
      card.name_from_mark! mark, opts
    end
    # need to load modules here to call the right virtual? method
    card.include_set_modules unless opts[:skip_modules]
    card if opts[:new] || card.known?
  end

  def fetch_soft mark, opts={}
    fetch mark, opts.merge(local_only: true)
  end

  def fetch_id *args
    mark, _opts = normalize_fetch_args args
    if mark.is_a?(Integer)
      mark
    else
      card = quick_fetch mark.to_s
      card && card.id
    end
  end

  def quick_fetch mark
    fetch mark, skip_virtual: true, skip_modules: true
  end

  def assign_or_initialize_by name, attributes, fetch_opts={}
    if (known_card = Card.fetch(name, fetch_opts))
      known_card.refresh.assign_attributes attributes
      known_card
    else
      Card.new attributes.merge(name: name)
    end
  end

  def [] *marks
    fetch(*marks, skip_virtual: true)
  end

  def exists? mark
    card = quick_fetch mark
    card.present?
  end

  def known? mark
    card = fetch mark, skip_modules: true
    card.present?
  end

  def expire_hard name
    return unless Card.cache.hard
    key = name.to_name.key
    Card.cache.hard.delete key
    Card.cache.hard.delete "~#{card.id}" if card.id
  end

  def expire name
    # note: calling instance method breaks on dirty names
    key = name.to_name.key
    return unless (card = Card.cache.read key)
    Card.cache.delete key
    Card.cache.delete "~#{card.id}" if card.id
  end

  def validate_fetch_opts! opts
    return unless opts[:new] && opts[:skip_virtual]
    raise Card::Error, "fetch called with new args and skip_virtual"
  end

  def cache
    Card::Cache[Card]
  end

  def fetch_from_cache cache_key, local_only=false
    return unless Card.cache
    if local_only
      Card.cache.soft.read cache_key
    else
      Card.cache.read cache_key
    end
  end

  def parse_mark! mark
    # return mark_type, mark_value, and absolutized mark
    if mark.is_a? Integer
      [:id, mark]
    else
      [:key, mark.key]
    end
  end

  def fetch_existing mark, opts
    return [nil, false] unless mark.present?
    mark_type, mark_key = parse_mark! mark
    needs_caching = false # until proven true :)

    # look in cache
    card = send "fetch_from_cache_by_#{mark_type}", mark_key, opts[:local_only]

    if retrieve_from_db?(card, opts)
      # look in db if needed
      card = fetch_from_db mark_type, mark_key, opts
      needs_caching = !card.nil? && !card.trash
    end

    [card, needs_caching]
  end

  def retrieve_from_db? card, opts
    card.nil? || (opts[:look_in_trash] && card.new_card? && !card.trash)
  end

  def fetch_from_cache_by_id id, local_only=false
    name = fetch_from_cache "~#{id}", local_only
    fetch_from_cache name, local_only if name
  end

  def fetch_from_cache_by_key key, local_only=false
    fetch_from_cache key, local_only
  end

  def fetch_from_db mark_type, mark_key, opts
    query = { mark_type => mark_key }
    query[:trash] = false unless opts[:look_in_trash]
    card = Card.where(query).take
    card
  end

  def new_for_cache card, name, opts
    return if name.is_a? Integer
    return if name.blank? && !opts[:new]
    return if card && (card.type_known? || skip_type_lookup?(opts))
    new name: name,
        skip_modules: true,
        skip_type_lookup: skip_type_lookup?(opts)
  end

  def skip_type_lookup? opts
    # if opts[:new] is not empty then we are initializing a variant that is
    # different from the cached variant
    # and can postpone type lookup for the cached variant
    # if skipping virtual no need to look for actual type
    opts[:skip_virtual] || opts[:new].present? || opts[:skip_type_lookup]
  end

  def write_to_cache card, opts
    if opts[:local_only]
      write_to_soft_cache card
    elsif Card.cache
      Card.cache.write card.key, card
      Card.cache.write "~#{card.id}", card.key if card.id && card.id != 0
    end
  end

  def write_to_soft_cache card
    return unless Card.cache
    Card.cache.soft.write card.key, card
    Card.cache.soft.write "~#{card.id}", card.key if card.id && card.id != 0
  end

  def compose_mark parts, opts
    return normalize_mark(parts.first, opts) if parts.size == 1
    parts.map do |p|
      normalized = normalize_mark p, {}
      normalized.is_a?(Integer) ? quick_fetch(normalized).name : normalized.to_s
    end.join("+").to_name
  end

  def normalize_fetch_args args
    opts = args.last.is_a?(Hash) ? args.pop : {}
    [compose_mark(args, opts), opts]
  end

  def normalize_mark mark, opts
    case mark
    when Symbol  then Card::Codename[mark]
    when Integer then mark.to_i
    when Card    then mark.cardname
    when String, SmartName
      # there are some situations where this breaks if we use Card::Name
      # rather than SmartName, which would seem more correct.
      # very hard to reproduce, not captured in a spec :(
      case mark.to_s
      when /^\~(\d+)$/ then $1.to_i                   # id
      when /^\:(\w+)$/ then Card::Codename[$1.to_sym] # codename
      else fullname_from_mark mark, opts[:new]        # name
      end
    end
  end

  def fullname_from_mark name, new_opts={}
    if new_opts && (supercard = new_opts[:supercard])
      name.to_name.to_absolute_name supercard.name
    else
      name.to_name
    end
  end
end

# ~~~~~~~~~~ Instance ~~~~~~~~~~~~~

def fetch opts={}
  traits = opts.delete(:trait)
  return unless traits
  # should this fail as an incorrect api call?
  traits = Array.wrap traits
  traits.inject(self) do |card, trait|
    Card.fetch card.cardname.trait(trait), opts
  end
end

def renew args={}
  opts = args[:new].clone
  handle_default_content opts
  opts[:name] ||= cardname
  opts[:skip_modules] = args[:skip_modules]
  Card.new opts
end

def handle_default_content opts
  if (default_content = opts.delete(:default_content)) && db_content.blank?
    opts[:content] ||= default_content
  elsif db_content.present? && !opts[:content]
    # don't overwrite existing content
    opts[:content] = db_content
  end
end

def expire_pieces
  cardname.piece_names.each do |piece|
    Card.expire piece
  end
end

def expire_hard
  return unless Card.cache.hard
  Card.cache.hard.delete key
  Card.cache.hard.delete "~#{id}" if id
end

def expire_soft
  Card.cache.soft.delete key
  Card.cache.soft.delete "~#{id}" if id
end

def expire
  expire_hard
  expire_soft
end

def refresh force=false
  if force || frozen? || readonly?
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

def type_known?
  type_id.present?
end

def name_from_mark! mark, opts
  return if opts[:local_only]
  return unless mark && mark.to_s != name
  self.name = mark.to_s
end
