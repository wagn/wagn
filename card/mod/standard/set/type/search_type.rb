include_set Abstract::AceEditor
include_set Abstract::WqlSearch

format do
  view :core, cache: :never do
    _render(
      case search_with_params
      when Exception          then :search_error
      when Integer            then :search_count
      when @mode == :template then :raw
      else                         :card_list
      end
    )
  end

  def chunk_list
    :query
  end
end

format :json do
  view :export do |args|
    # avoid running the search from options and structure that
    # case a huge result or error
    return [render_atom(args)] if card.content.empty? ||
                                  card.name.include?("+*options") ||
                                  card.name.include?("+*structure")
    super(args)
  end

  view :export_items, cache: :never do |args|
    card.item_names(limit: 0).map do |i_name|
      next unless (i_card = Card[i_name])
      subformat(i_card).render_atom(args)
    end.flatten.reject(&:blank?)
  end
end

format :rss do
  view :feed_body do
    case raw_feed_items
    when Exception then @xml.item(render(:search_error))
    when Integer then @xml.item(render(:search_count))
    else super()
    end
  end

  def raw_feed_items
    @raw_feed_items ||= search_with_params
  end
end

format :html do
  view :closed_content, cache: :never do
    if @depth > max_depth
      "..."
    else
      search_params[:limit] = closed_limit
      _render_core hide: "paging", items: { view: :link }
      # TODO: if item is queryified to be "name", then that should work.
      # otherwise use link
    end
  end

  def default_editor_args args
    args[:ace_mode] = "json"
  end
end
