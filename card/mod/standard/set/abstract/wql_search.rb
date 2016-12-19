include_set Abstract::Search

def search args={}
  statement = fetch_query args
  raise "OH NO.. no limit" unless statement[:limit]
  # forces explicit limiting
  # can be 0 or less to force no limit
  Query.run statement, name
end

# def raw_ruby_query
#   raise Error::BadQuery, "override 'raw_ruby_query'"
# end

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

# override this with a wql hash to define search
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
  def default_search_params
    @default_search_params ||= { limit: (card_content_limit || default_limit) }
  end

  def card_content_limit
    card.raw_ruby_query[:limit]
  rescue
    nil
  end

  def query_with_params
    @query_with_params ||= card.fetch_query search_params
  end

  def limit
    query_with_params[:limit]
  end
end
