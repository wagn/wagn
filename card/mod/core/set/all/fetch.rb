# = Card#fetch
#
# A multipurpose retrieval operator that integrates caching, database lookups,
# and "virtual" card construction
module ClassMethods
  # Look for cards in
  # * cache
  # * database
  # * virtual cards
  #
  # @param args [Integer, String, Card::Name, Symbol]
  #    one or more of the three unique identifiers
  #      1. a numeric id (Integer)
  #      2. a name/key (String or Card::Name)
  #      3. a codename (Symbol)
  #    If you pass more then one mark they get joined with a '+'.
  #    The final argument can be a hash to set the following options
  #      :skip_virtual               Real cards only
  #      :skip_modules               Don't load Set modules
  #      :look_in_trash              Return trashed card objects
  #      :local_only                 Use only local cache for lookup and storing
  #      new: { opts for Card#new }  Return a new card when not found
  # @return [Card]
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

  def fetch_name mark
    if (card = quick_fetch(mark))
      card.name
    elsif block_given?
      yield
    end
  end

  def fetch_type_id mark
    (card = quick_fetch(mark)) && card.type_id
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

  def validate_fetch_opts! opts
    return unless opts[:new] && opts[:skip_virtual]
    raise Card::Error, "fetch called with new args and skip_virtual"
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

  def deep_fetch args
    opts = deep_opts args
    if args[:action] == "create"
      # FIXME: we currently need a "new" card to catch duplicates
      # (otherwise save will just act like a normal update)
      # We may need a "#create" instance method to handle this checking?
      Card.new opts
    else
      mark = args[:id] || opts[:name]
      Card.fetch mark, look_in_trash: args[:look_in_trash], new: opts
    end
  end

  def fetch_from_cast cast
    fetch_args = cast[:id] ? [cast[:id].to_i] : [cast[:name], { new: cast }]
    Card.fetch(*fetch_args)
  end

  def cardish cardish
    if cardish.is_a? Card
      cardish
    else
      fetch cardish, new: {}
    end
  end

  def deep_opts args
    opts = (args[:card] || {}).clone
    # clone so that original params remain unaltered.  need deeper clone?
    opts[:type] ||= args[:type] if args[:type]
    # for /new/:type shortcut.  we should handle in routing and deprecate this
    opts[:name] ||= Card::Name.url_key_to_standard(args[:id])
    opts
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

  def compose_mark parts, opts={}
    parts.flatten!
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
    when Symbol            then require_id_for_codename mark
    when Integer           then mark.to_i
    when Card              then mark.cardname
    when String, SmartName then normalize_stringy_mark mark, opts
      # there are some situations where this breaks if we use Card::Name
      # rather than SmartName, which would seem more correct.
      # very hard to reproduce, not captured in a spec :(
    end
  end

  def normalize_stringy_mark mark, opts
    case mark.to_s
    when /^\~(\d+)$/  # id, eg "~75"
      Regexp.last_match[1].to_i
    when /^\:(\w+)$/  # codename, eg ":options"
      require_id_for_codename(Regexp.last_match[1].to_sym)
    else
      fullname_from_mark mark, opts[:new]
    end
  end

  def require_id_for_codename mark
    id = Card::Codename[mark]
    raise Card::Error::NotFound, "missing card with codename: #{mark}" unless id
    id
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

def expire cache_type=nil
  return unless (cache_class = cache_class_from_type cache_type)
  expire_views
  expire_names cache_class
  expire_id cache_class
end

def cache_class_from_type cache_type
  cache_type ? Card.cache.send(cache_type) : Card.cache
end

def register_view_cache_key cache_key
  view_cache_keys cache_key
  hard_write_view_cache_keys
end

def view_cache_keys new_key=nil
  @view_cache_keys ||= []
  @view_cache_keys << new_key if new_key
  append_missing_view_cache_keys
  @view_cache_keys.uniq!
end

def append_missing_view_cache_keys
  return unless Card.cache.hard
  @view_cache_keys +=
    (Card.cache.hard.read_attribute(key, :view_cache_keys) || [])
end

def hard_write_view_cache_keys
#  puts "WRITE VIEW CACHE KEYS (#{name}): #{view_cache_keys}"
  return unless Card.cache.hard
  Card.cache.hard.write_attribute key, :view_cache_keys, @view_cache_keys
end

def expire_views
#  puts "EXPIRE VIEW CACHE (#{name}): #{view_cache_keys}"
  return unless view_cache_keys.present?
  Array.wrap(@view_cache_keys).each do |view_cache_key|
    Card::View.cache.delete view_cache_key
  end
  @view_cache_keys = nil
end

def expire_names cache
  [name, name_was].each do |name_version|
    expire_name name_version, cache
  end
end

def expire_name name_version, cache
  return unless name_version.present?
  key_version = name_version.to_name.key
  return unless key_version.present?
  cache.delete key_version
end

def expire_id cache
  return unless id.present?
  cache.delete "~#{id}"
end

def refresh force=false
  return self unless force || frozen? || readonly?
  fresh_card = self.class.find id
  fresh_card.include_set_modules
  fresh_card
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
