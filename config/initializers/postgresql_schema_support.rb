# Drop this file into config/initializers to enable PostgreSQL schema
# support in ActiveRecord. Then, you can do things like this in your
# models:
#
# set_table_name "schema.table"
#
# See https://rails.lighthouseapp.com/projects/8994/tickets/390
# for original patch.

class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def quote_table_name(name)
    schema, name_part = extract_pg_identifier_from_name(name.to_s)
    return quote_column_name(schema) unless name_part
    table_name, name_part = extract_pg_identifier_from_name(name_part)
    "#{quote_column_name(schema)}.#{quote_column_name(table_name)}"
  end

  # Quotes column names for use in SQL queries.
  def quote_column_name(name) #:nodoc:
    PGconn.quote_ident(name.to_s)
  end

  def schema_search_path=(schema_csv)
    if schema_csv
      execute "SET search_path TO \"#{schema_csv}\""
      @schema_search_path = schema_csv
    end
  end

  private

  def extract_pg_identifier_from_name(name)
    if name[0,1] == '"'
      match_data = name.match(/\"([^\"]+)\"/)
    else
      match_data = name.match(/([^\.]+)/)
    end
    if match_data
      rest = name[match_data[0].length..-1]
      rest = rest[1..-1] if rest[0,1] == "."
      return match_data[1], (rest.length > 0 ? rest : nil)
    end
    return nil, nil
  end
end

