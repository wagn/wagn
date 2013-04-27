# -*- encoding : utf-8 -*-
module ActiveRecord
  class SchemaDumper
    def dump(stream)
      header(stream)
      tables(stream)
      #views(stream)
      trailer(stream)
      stream
    end

    private
    def views(stream)
      views = @connection.select_all("SELECT viewname  FROM pg_views WHERE schemaname IN ('$user','public');")
      views.each do |view|
        view( view['viewname'], stream )
      end
    end

    def view(viewname, stream)
      viewinfo = @connection.select_one %{
        SELECT * from pg_views WHERE schemaname IN ('$user','public')
        and viewname='#{viewname}'
      }
      stream.puts <<ENDVIEW
  execute %{
    CREATE VIEW #{viewname} AS
    #{viewinfo['definition']}
  }

ENDVIEW
    end

  end
end
