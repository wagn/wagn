include_set Abstract::AceEditor
include_set Abstract::WqlSearch

def raw_ruby_query
  @raw_ruby_query ||= begin
    query = raw_content
    query = query.is_a?(Hash) ? query : parse_json_query(query)
    query.symbolize_keys
  end
end

def parse_json_query query
  empty_query_error! if query.empty?
  JSON.parse query
rescue
  raise Error::BadQuery, "Invalid JSON search query: #{query}"
end

def empty_query_error!
  raise Error::BadQuery,
        "Error in card '#{name}':can't run search with empty content"
end

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
    @raw_feed_items ||= begin
      search_params[:default_limit] = 25
      search_with_params
    end
  end
end

format :html do
  view :closed_content do
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
