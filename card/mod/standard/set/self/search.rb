include_set Abstract::SearchParams

format do
  def default_search_params
    hash = super
    hash[:vars] = params[:vars] || {}
    params.each do |key, val|
      next unless key.to_s =~ /^\_(\w+)$/
      hash[:vars][Regexp.last_match(1).to_sym] = val
    end
    hash
  end
end

format :html do
  def extra_paging_path_args
    vars = query_with_params.vars
    return {} unless vars.is_a? Hash
    vars.each_with_object({}) do |(key, value), hash|
      hash["_#{key}"] = value
    end
  end

  view :title, cache: :never do
    vars = root.search_params[:vars]
    if vars && vars[:keyword]
      voo.title = %(Search results for: <span class="search-keyword">)\
                         "#{vars[:keyword]}</span>"
    end
    super()
  end
end

format :json do
  view :complete, cache: :never do
    term = complete_term
    exact = Card.fetch term, new: {}

    {
      search: true,
      add: add_item(exact),
      new: new_item_of_type(exact),
      goto: goto_items(term, exact)
    }
  end

  def add_item exact
    return unless exact.new_card? &&
                  exact.cardname.valid? &&
                  !exact.virtual? &&
                  exact.ok?(:create)
    exact.name
  end

  def new_item_of_type exact
    return unless (exact.type_id == Card::CardtypeID) &&
                  Card.new(type_id: exact.id).ok?(:create)
    [exact.name, exact.cardname.url_key]
  end

  def goto_items term, exact
    goto_names = Card.search goto_wql(term), "goto items for term: #{term}"
    goto_names.unshift exact.name if add_exact_to_goto_names? exact, goto_names
    goto_names.map do |name|
      [name, highlight(name, term), name.to_name.url_key]
    end
  end

  def add_exact_to_goto_names? exact, goto_names
    exact.known? && !goto_names.find { |n| n.to_name.key == exact.key }
  end

  def complete_term
    term = params["_keyword"]
    if (term =~ /^\+/) && (main = params["main"])
      term = main + term
    end
    term
  end

  # hacky.  here for override
  def goto_wql term
    { complete: term, limit: 8, sort: "name", return: "name" }
  end
end
