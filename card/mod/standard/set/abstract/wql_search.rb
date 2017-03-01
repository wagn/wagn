include_set Abstract::Search

def search args={}
  query = fetch_query(args)
  # forces explicit limiting
  # can be 0 or less to force no limit
  raise "OH NO.. no limit" unless query.mods[:limit]
  query.run
end

# override this to define search
def wql_hash
  @wql_hash ||= begin
    query = raw_content
    query = query.is_a?(Hash) ? query : parse_json_query(query)
    query.symbolize_keys
  end
end

def query args={}
  query_args = wql_hash.merge args
  query_args = standardized_query_args query_args
  Query.new query_args, name
end

def fetch_query args={}
  @query ||= {}
  @query[args.to_s] ||= query(args.clone) # cache query
end

def standardized_query_args args
  args = args.symbolize_keys
  args[:context] ||= cardname
  args
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
  def default_search_params
    @default_search_params ||= { limit: (card_content_limit || default_limit) }
  end

  def card_content_limit
    card.wql_hash[:limit]
  rescue
    nil
  end

  def query_with_params
    @query_with_params ||= card.fetch_query search_params
  end

  def limit
    query_with_params.limit
  end
end
