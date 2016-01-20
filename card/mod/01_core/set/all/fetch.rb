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
  def fetch mark, opts={}
    validate_fetch_opts! opts
    mark = normalize_mark mark, opts

    card, needs_caching = fetch_existing mark, opts

    if (new_card = new_for_cache card, mark, opts)
      card = new_card
      needs_caching = true
    end

    return if card.nil?
    write_to_cache card, opts if needs_caching
    standard_fetch_results card, mark, opts
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

  def fetch_id mark, opts={}
    mark = normalize_mark mark, opts
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

  def [] mark
    fetch mark, skip_virtual: true
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

  def expire name, subcards=false
    # note: calling instance method breaks on dirty names
    key = name.to_name.key
    return unless (card = Card.cache.read key)
    if subcards
      card.expire_subcards
    else
      card.preserve_subcards
    end
    Card.cache.delete key
    Card.cache.delete "~#{card.id}" if card.id
  end

  # set_names reverse map (cached)
  # FIXME: move to set handling
  def cached_set_members key
    set_cache_list = Card.cache.read "$#{key}"
    set_cache_list.nil? ? [] : set_cache_list.keys
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
    return unless opts[:new] && opts[:skip_virtual]
    fail Card::Error, 'fetch called with new args and skip_virtual'
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
    return [nil, false] if !mark.present?
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
    card.restore_subcards if card
    card
  end

  def new_for_cache card, name, opts
    return if name.is_a? Integer
    return if !name.present? && !opts[:new]
    return unless !card || (card.type_unknown? && !skip_type_lookup?(opts))
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

  def normalize_mark mark, opts
    case mark
    when Symbol        then Card::Codename[mark]
    when Integer       then mark.to_i
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
  if (default_content = opts.delete(:default_content)) && db_content.empty?
    opts[:content] ||= default_content
  elsif db_content.present? && !opts[:content]
    # don't overwrite existing content
    opts[:content] = db_content
  end
end

def expire_pieces
  cardname.piece_names.each do |piece|
    Card.expire piece, !cardname.field_of?(piece)
  end
end

def expire_hard
  return unless Card.cache.hard
  Card.cache.hard.delete key
  Card.cache.hard.delete "~#{id}" if id
end

def expire_soft subcards=false
  if subcards
    expire_subcards
  else
    preserve_subcards
  end
  Card.cache.soft.delete key
  Card.cache.soft.delete "~#{id}" if id
end

def expire subcards=false
  expire_hard
  expire_soft subcards
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

def type_unknown?
  type_id.nil?
end

def name_from_mark! mark, opts
  return if opts[:local_only]
  return unless mark && mark.to_s != name
  self.name = mark.to_s
end
