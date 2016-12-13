include_set Abstract::AceEditor

def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  # forces explicit limiting
  # can be 0 or less to force no limit
  Query.run(s, name)
end

def item_names params={}
  statement = query params.merge(return: :name)
  Query.run(statement, name)
end

def item_type
  return if query[:type].is_a?(Array) || query[:type].is_a?(Hash)
  query[:type]
end

def each_item_name_with_options _content=nil
  options = {}
  options[:view] = query[:item] if query && query[:item]
  item_names.each do |name|
    yield name, options
  end
end

def count params={}
  Card.count_by_wql query(params)
end

def query params={}
  @query ||= {}
  @query[params.to_s] ||= get_query(params.clone)
end

def raw_ruby_query override
  raw_query = override || raw_content
  return raw_query if raw_query.is_a? Hash # does this happen?
  parse_json_query raw_query
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

def get_query params={}
  # why is this a wagn_bot thing?  can't deny search content??
  query_override = params.delete :query
  standardize_query raw_ruby_query(query_override), params
end

def standardize_query query, params
  query = query.symbolize_keys.merge params.symbolize_keys
  default_limit = query.delete :default_limit
  query[:limit] ||= default_limit if default_limit
  query[:context] ||= cardname
  query
end

format do
  view :core, cache: :never do
    view =
      case search_results
      when Exception          then :search_error
      when Integer            then :search_count
      when @mode == :template then :raw
      else                         :card_list
      end
    _render view
  end

  view :search_count, cache: :never do
    search_results.to_s
  end

  view :search_error, cache: :never do
    sr_class = search_results.class.to_s
    %(#{sr_class} :: #{search_results.message} :: #{card.raw_content})
  end

  view :card_list, cache: :never do
    if search_results.empty?
      "no results"
    else
      search_results.map do |item_card|
        nest_item item_card
      end.join "\n"
    end
  end

  def search_results
    @search_results ||= prepare_query && run_query
  rescue Error::BadQuery => e
    e
  end

  def prepare_query
    @query_hash = card.query search_params
  end

  def run_query
    raw_results = card.item_cards search_params
    @query_hash[:return] == "count" ? raw_results.to_i : raw_results
  end

  def search_result_names
    @search_result_names ||=
      begin
        card.item_names search_params
      rescue => e
        { error: e }
      end
  end

  def implicit_item_view
    view = voo_items_view || @query_hash[:item] || default_item_view
    Card::View.canonicalize view
  end

  def chunk_list
    :query
  end
end

format :data do
  view :card_list do |_args|
    search_results.map do |item_card|
      nest_item item_card
    end
  end
end

format :csv do
  view :card_list do |args|
    items = super args
    if @depth.zero?
      render_csv_title_row + items
    else
      items
    end
  end
end

format :json do
  def default_search_params
    set_default_search_params default_limit: 0
  end

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
      search_results
    end
  end
end

format :html do
  def default_editor_args args
    args[:ace_mode] = "json"
  end

  view :card_list do
    return render_no_search_results if search_results.empty?
    search_result_list do
      search_results.map do |item_card|
        nest_item item_card, size: voo.size do |rendered, item_view|
          klass = "search-result-item item-#{item_view}"
          %(<div class="#{klass}">#{rendered}</div>)
        end
      end
    end
  end

  def search_result_list
    with_paging do
      wrap_with :div, class: "search-result-list" do
        yield
      end
    end
  end

  def with_paging
    output [yield, _optional_render_paging]
    #paging =
    #output [paging, yield, (paging if search_results.size > 10)]
  end

  view :closed_content do |args|
    if @depth > max_depth
      "..."
    else
      search_params[:limit] =
        [search_params[:limit].to_i, Card.config.closed_search_limit].min
      _render_core hide: "paging", items: { view: :link }
      # TODO: if item is queryified to be "name", then that should work.
      # otherwise use link
    end
  end

  view :no_search_results do
    wrap_with :div, "", class: "search-no-results"
  end

  def default_search_params
    set_default_search_params default_limit: 20
  end
end
