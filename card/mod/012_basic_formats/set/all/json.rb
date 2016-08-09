
format :json do
  def get_nest_defaults _nested_card
    { view: :atom }
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
    if raw.is_a?(String)
      raw
    elsif params[:compress]
      JSON(raw)
    else
      JSON.pretty_generate raw
    end
  end

  view :name_complete do |_args|
    card.item_cards complete: params["term"], limit: 8, sort: "name",
                    return: "name", context: ""
  end

  view :status, tags: :unknown_ok, perms: :none do |_args|
    status =
      case
      when !card.known?     then :unknown
      # do we want the following to prevent fishing?  of course, they can always
      # post...
      when !card.ok?(:read) then :unknown
      when card.real?       then :real
      when card.virtual?    then :virtual
      else :wtf
      end

    hash = { key: card.key, url_key: card.cardname.url_key, status: status }
    hash[:id] = card.id if status == :real

    hash
  end

  view :content do |_args|
    req = controller.request
    {
      url:       (req && req.original_url),
      timestamp: Time.now.to_s,
      card:      _render_atom
    }
  end

  view :atom do |args|
    h = {
      name: card.name,
      type: card.type_name
    }
    h[:content]  = card.content  unless card.structure
    h[:codename] = card.codename     if card.codename
    h[:value]    = _render_core args if @depth < max_depth
    h
  end
end
