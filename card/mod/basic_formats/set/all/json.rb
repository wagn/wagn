format :json do
  AUTOCOMPLETE_LIMIT = 8 # number of name suggestions for autocomplete text fields

  def default_nest_view
    :atom
  end

  def default_item_view
    params[:item] || :atom
  end

  def max_depth
    params[:max_depth] || 1
  end

  def show view, args
    view ||= :content
    raw = render view, args
    return raw if raw.is_a? String
    method = params[:compress] ? :generate : :pretty_generate
    JSON.send method, raw
  end

  view :name_complete, cache: :never do
    name_search
  end

  view :junction_name_complete, cache: :never do
    name_search query_attribute: :junction_complete
  end

  view :name_match, cache: :never do
    starts_with = name_search query_attribute: :junction_complete
    remaining_slots = AUTOCOMPLETE_LIMIT - starts_with.size
    return starts_with if remaining_slots.zero?
    starts_with + name_search(query_attribute: :name_match,
                              limit: remaining_slots)
  end

  def name_search query_attribute: :complete, limit: AUTOCOMPLETE_LIMIT
    # context is "" so that term will not be interpreted in the context
    # of search card name.  However, this can break searches where the
    # search card name is required (eg found_by)
    card.search limit: limit, sort: "name", return: "name", context: "",
                query_attribute => params[:term]
  end

  view :status, tags: :unknown_ok, perms: :none, cache: :never do
    status = card.state
    hash = { key: card.key,
             url_key: card.cardname.url_key,
             status: status }
    hash[:id] = card.id if status == :real
    hash
  end

  view :content, cache: :never do
    { url: request_url,
      timestamp: Time.now.to_s,
      card: _render_atom }
  end

  view :atom, cache: :never do
    h = { name: card.name, type: card.type_name }
    h[:content] = card.content unless card.structure
    h[:codename] = card.codename if card.codename
    h[:value] = _render_core if @depth < max_depth
    h
  end

  # minimum needed to re-fetch card
  view :cast, cache: :never do
    card.cast
  end

  view :marks do
    {
      id: card.id,
      name: card.name,
      url: path
    }
  end

  view :essentials do
    if voo.show? :marks
      render_marks.merge(essentials)
    else
      essentials
    end
  end

  def essentials
    return {} if card.structure
    { content: card.content }
  end

  def request_url
    req = controller.request
    req ? req.original_url : path
  end
end

# TODO: perhaps this should be in a general "data" module.
def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end
