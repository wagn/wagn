namespace :wagn do
  task :prepare_fulltext => :environment do
    cxn = ActiveRecord::Base.connection
    if System.enable_postgres_fulltext and cxn.class.to_s.split('::').last == 'PostgreSQLAdapter' and !Card.columns.plot(:name).include?('indexed_content')
       db = ActiveRecord::Base.configurations[RAILS_ENV]["database"]
       user = ActiveRecord::Base.configurations[RAILS_ENV]["username"]    

       # NOTE: this will only work if the user running the migration has sudo priveleges
      `sudo -u postgres psql #{db} < #{System.postgres_src_dir}/contrib/tsearch2/tsearch2.sql`
       cmd = %{ echo "alter table pg_ts_cfg owner to #{user}; } +
         %{ alter table pg_ts_cfgmap owner to #{user}; } + 
         %{ alter table pg_ts_dict owner to #{user}; } + 
         %{ alter table pg_ts_parser owner to #{user};" | sudo -u postgres psql #{db}
       }
       `#{cmd}`

      cxn.execute %{ alter table cards add column indexed_content tsvector }
      cxn.execute %{
        update cards set indexed_content = concat( setweight( to_tsvector( name ), 'A' ), 
        to_tsvector( (select content from revisions where id=cards.current_revision_id) ) ) 
      }     
      # choosing GIST for faster updates, at least for now.
      # see: http://www.postgresql.org/docs/8.3/static/textsearch-indexes.html
      cxn.execute %{ CREATE INDEX name ON cards USING gist(indexed_content);  }    
      cxn.execute %{ vacuum full analyze }
    else
      # FIXME: do whatever needs to happen for mysql? sqlite?
      #add_column :cards, :indexed_content, :text
    end                  
    
  end
end