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

def count params={}
  Card.count_by_wql query(params)
end

def query params={}
  @query ||= {}
  @query[params.to_s] ||= get_query(params.clone)
end

def get_query params={}
  # why is this a wagn_bot thing?  can't deny search content??
  query = Auth.as_bot do
    query_content = params.delete(:query) || raw_content
    if query_content.empty?
      raise JSON::ParserError,
            "Error in card '#{name}':can't run search with empty content"
    elsif query_content.is_a?(String)
      JSON.parse(query_content)
    else query_content
    end
  end
  query.symbolize_keys!.merge! params.symbolize_keys
  if (default_limit = query.delete(:default_limit))
    query[:limit] ||= default_limit
  end
  query[:context] ||= cardname
  query
end

format do
  view :core do |args|
    view =
      case search_results args
      when Exception          then :search_error
      when Integer            then :search_count
      when @mode == :template then :raw
      else                         :card_list
      end
    _render view, args
  end

  view :search_count do |_args|
    search_results.to_s
  end

  view :search_error do |_args|
    sr_class = search_results.class.to_s
    %(#{sr_class} :: #{search_results.message} :: #{card.raw_content})
  end

  view :card_list do |_args|
    if search_results.empty?
      "no results"
    else
      search_results.map do |c|
        nest c
      end.join "\n"
    end
  end

  def search_vars args={}
    @search_vars ||=
      begin
        v = {}
        v[:query] = card.query(search_params)
        v[:item] = set_nest_opts args.merge(query_view: v[:query][:view])
        v
      rescue JSON::ParserError => e
        { error: e }
      end
  end

  def search_results args={}
    @search_results ||= begin
      search_vars args
      if search_vars[:error]
        search_vars[:error]
      else
        begin
          raw_results = card.item_cards search_params
          is_count = search_vars[:query][:return] == "count"
          is_count ? raw_results.to_i : raw_results
        rescue BadQuery => e
          e
        end
      end
    end
  end

  def search_result_names
    @search_result_names ||=
      begin
        card.item_names search_params
      rescue => e
        { error: e }
      end
  end

  def each_reference_with_args args={}
    search_result_names.each do |name|
      yield(name, nest_args(args.reverse_merge!(item: :content)))
    end
  end

  def set_nest_opts args
    @nest_defaults = nil
    @nest_opts ||= {}
    @nest_opts[:view] = args[:item] || nest_opts[:view] ||
                        args[:query_view] || default_item_view
    # explicit > nest syntax > WQL > nest defaults
  end

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    link_to raw(text), path(@paging_path_args), options
  end

  def page_li text, page, current=false, options={}
    css_class = if current
                  "active"
                elsif !page
                  "disabled"
                end
    page ||= 0
    content_tag :li, class: css_class do
      page_link text, page, current, options
    end
  end

  def previous_page_link page
    page_li '<span aria-hidden="true">&laquo;</span>', page, false,
            "aria-label" => "Previous"
  end

  def next_page_link page
    page_li '<span aria-hidden="true">&raquo;</span>', page, false,
            "aria-label" => "Next"
  end

  def ellipse_page
    content_tag :li, content_tag(:span, "...")
  end

  def chunk_list
    :query
  end
end

format :data do
  view :card_list do |_args|
    search_results.map do |c|
      nest c
    end
  end
end

format :csv do
  view :card_list do |args|
    items = super args
    if @depth == 0
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

  view :export_items do |args|
    card.item_names(limit: 0).map do |i_name|
      next unless (i_card = Card[i_name])
      subformat(i_card).render_atom(args)
    end.flatten.reject(&:blank?)
  end
end

format :rss do
  view :feed_body do |args|
    case raw_feed_items args
    when Exception then @xml.item(render(:search_error))
    when Integer then @xml.item(render(:search_count))
    else super args
    end
  end

  def raw_feed_items _args
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

  view :card_list do |args|
    paging = _optional_render :paging, args

    if search_results.empty?
      render_no_search_results(args)
    else
      results =
        search_results.map do |c|
          item_view = nest_defaults(c)[:view]
          %(
            <div class="search-result-item item-#{item_view}">
              #{nest(c, size: args[:size], view: item_view)}
            </div>
          )
        end.join "\n"

      %(
        #{paging}
        <div class="search-result-list">
          #{results}
        </div>
        #{paging if search_results.length > 10}
      )
    end
  end

  view :closed_content do |args|
    if @depth > self.class.max_depth
      "..."
    else
      search_limit = args[:closed_search_limit]
      search_params[:limit] =
        search_limit && [search_limit, Card.config.closed_search_limit].min
      _render_core args.merge(hide: "paging", item: :link)
      # TODO: if item is queryified to be "name", then that should work.
      # otherwise use link
    end
  end

  view :no_search_results do |_args|
    %(<div class="search-no-results"></div>)
  end

  view :paging do |args|
    s = card.query search_params
    offset = s[:offset].to_i
    limit = s[:limit].to_i
    return "" if limit < 1
    # avoid query if we know there aren't enough results to warrant paging
    return "" if offset == 0 && limit > offset + search_results.length
    total = card.count search_params
    # should only happen if limit exactly equals the total
    return "" if limit >= total
    @paging_path_args = { limit: limit,
                          slot: {
                            item: args[:item] || nest_defaults(card)[:view]
                          } }
    @paging_path_args[:view] = args[:home_view] if args[:home_view]
    @paging_limit = limit

    s[:vars].each { |key, value| @paging_path_args["_#{key}"] = value }

    out = ['<nav><ul class="pagination paging">']

    total_pages = ((total - 1) / limit).to_i
    current_page = (offset / limit).to_i # should already be integer
    window = 2 # should be configurable
    window_min = current_page - window
    window_max = current_page + window

    previous_page = current_page > 0 ? current_page - 1 : false
    out << previous_page_link(previous_page)
    if window_min > 0
      out << page_li(1, 0)
      out << ellipse_page if window_min > 1
    end

    (window_min..window_max).each do |page|
      next if page < 0 || page > total_pages
      text = page + 1
      out << page_li(text, page, page == current_page)
    end

    if total_pages > window_max
      out << ellipse_page if total_pages > window_max + 1
      out << page_li(total_pages + 1, total_pages)
    end

    next_page = current_page < total_pages ? current_page + 1 : false
    out << next_page_link(next_page)

    out << %(</ul></nav>)
    out.join
  end

  def default_search_params
    set_default_search_params default_limit: 20
  end
end
