## These are copied from rails trunk-- so the definitions here can go away at some point
namespace :db do  
  desc 'Creates the databases defined in your config/database.yml (unless they already exist)'
  task :create => :environment do 
    ActiveRecord::Base.configurations.each_value do |config|
      begin
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      rescue
        case config['adapter']
        when 'mysql'
          @charset   = ENV['CHARSET']   || 'utf8'
          @collation = ENV['COLLATION'] || 'utf8_general_ci'

          begin
            ActiveRecord::Base.establish_connection(config.merge({'database' => nil}))
            ActiveRecord::Base.connection.create_database(config['database'], {:charset => @charset, :collation => @collation})
            ActiveRecord::Base.establish_connection(config)
          rescue
            $stderr.puts "Couldn't create database for #{config.inspect}"
          end
        when 'postgresql'
          `createdb "#{config['database']}" -E utf8`  
        when 'sqlite'
          `sqlite "#{config['database']}"`
        when 'sqlite3'
          `sqlite3 "#{config['database']}"`
        end
      end
    end
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[RAILS_ENV || 'development'])
  end
  
  desc 'Drops the database for your currenet RAILS_ENV as defined in config/database.yml'
  task :drop => :environment do
    config = ActiveRecord::Base.configurations[RAILS_ENV || 'development']
    case config['adapter']
    when 'mysql'
      ActiveRecord::Base.connection.drop_database config['database']
    when /^sqlite/
      FileUtils.rm_f File.join(RAILS_ROOT, config['database'])
    when 'postgresql'
      `dropdb "#{config['database']}"`   
    end
  end
end