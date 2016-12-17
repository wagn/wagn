include_set Abstract::Search

def search args={}
  statement = fetch_query args
  raise("OH NO.. no limit") unless statement[:limit]
  # forces explicit limiting
  # can be 0 or less to force no limit
  Query.run(statement, name)
rescue
  binding.pry
end

def raw_ruby_query
  raise Error::BadQuery, "override 'raw_ruby_query'"
end

def query args={}
  raw_ruby_query.merge standardized_query_args(args)
end

def fetch_query args={}
  @query ||= {}
  @query[args.to_s] ||= query(args.clone) # cache query
end

def standardized_query_args args
  args.symbolize_keys!
  args[:context] ||= cardname
  args
end

format do
  def default_search_params
    @default_search_params ||=
      { limit: (card.raw_ruby_query[:limit] || default_limit) }
  end

  def query_with_params
    @query_with_params ||= card.fetch_query search_params
  end

  def limit
    query_with_params[:limit]
  end
end
