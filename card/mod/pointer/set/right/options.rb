def default_limit
  wql_limit = fetch_query.limit if respond_to?(:fetch_query)
  wql_limit || 50
end
