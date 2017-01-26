format do
  def search_params
    @search_params ||= begin
      p = default_search_params.clone
      offset_and_limit_search_params p if focal?
      p
    end
  end

  def default_search_params
    { limit: default_limit }
  end

  def default_limit
    100
  end

  def offset_and_limit_search_params hash
    [:offset, :limit].each do |key|
      hash[key] = params[key].to_i if params[key]
    end
  end
end

format :html do
  def default_limit
    Cardio.config.paging_limit || 20
  end
end

format :json do
  def default_limit
    0
  end
end

format :rss do
  def default_limit
    25
  end
end
