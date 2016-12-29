format :json do
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
    # context is "" so that term will not be interpreted in the context
    # of search card name.  However, this can break searches where the
    # search card name is required (eg found_by)
    card.search complete: params["term"], limit: 8, sort: "name",
                return: "name", context: ""
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
    req = controller.request
    { url:       (req && req.original_url),
      timestamp: Time.now.to_s,
      card:      _render_atom }
  end

  view :atom, cache: :never do
    h = { name: card.name, type: card.type_name }
    h[:content]  = card.content  unless card.structure
    h[:codename] = card.codename if card.codename
    h[:value]    = _render_core  if @depth < max_depth
    h
  end

  # minimum needed to re-fetch card
  view :cast, cache: :never do
    card.cast
  end
end

# TODO: perhaps this should be in a general "data" module.
def cast
  real? ? { id: id } : { name: name, type_id: type_id, content: db_content }
end

