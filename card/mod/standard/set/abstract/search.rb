include_set Abstract::SearchParams

def search _args={}
  raise Error, "search not overridden"
end

def cached_search args={}
  @search_results ||= {}
  @search_results[args.to_s] ||= search args
end

def returning item, args
  args[:return] = item
  yield
end

def item_cards args={}
  returning(:card, args) { search args }
end

def item_names args={}
  args[:limit] = 0
  returning(:name, args) { search args }
end

def count args={}
  args[:offset] = 0
  args[:limit] = 0
  returning(:count, args) { search args }
end

def item_type
  type = wql_hash[:type]
  return if type.is_a?(Array) || type.is_a?(Hash)
  type
end

def each_item_name_with_options _content=nil
  options = {}
  item = fetch_query.statement[:view]
  options[:view] = item if item
  item_names.each do |name|
    yield name, options
  end
end

format do
  view :search_count, cache: :never do
    search_with_params.to_s
  end

  view :search_error, cache: :never do
    sr_class = search_with_params.class.to_s
    %(#{sr_class} :: #{search_with_params.message} :: #{card.raw_content})
  end

  view :card_list, cache: :never do
    if search_with_params.empty?
      "no results"
    else
      search_with_params.map do |item_card|
        nest_item item_card
      end.join "\n"
    end
  end

  def search_with_params args={}
    query_args = search_params.merge args
    card.cached_search query_args
  rescue Error::BadQuery => e
    e
  end

  def count_with_params args={}
    search_with_params args.merge return: :count
  end

  def implicit_item_view
    view = voo_items_view || query_with_params.statement[:item] ||
      default_item_view
    Card::View.canonicalize view
  end
end

format :data do
  view :card_list do |_args|
    search_with_params.map do |item_card|
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

format :html do
  view :card_list do
    return render_no_search_results if search_with_params.empty?
    search_result_list do
      search_with_params.map do |item_card|
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

  def closed_limit
    [search_params[:limit].to_i, Card.config.closed_search_limit].min
  end

  view :no_search_results do
    wrap_with :div, "", class: "search-no-results"
  end
end
