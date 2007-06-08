require 'enumerator'

require_dependency 'wql/parser'
require_dependency 'wql/translator'
require_dependency 'wql/sql_statement'
require_dependency 'wql/query_generator'

Wql.extend( Wql::QueryGenerator ) 

module Wql
  def self.to_sql( wql )
    Wql::Parser.new().parse(wql).to_s
  end
end


