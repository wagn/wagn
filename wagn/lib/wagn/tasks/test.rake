def set_database( db )
  y = YAML.load_file("#{Wagn.root}/config/database.yml")
  y["development"]["database"] = db if y["development"]
  y["production"]["database"] = db if y["production"]

  File.open( "#{Wagn.root}/config/database.yml", 'w' ) do |out|
    YAML.dump( y, out )
  end
end



namespace :test do
  task :all => :environment do
    puts 'This is not yet working; only first invocation takes effect'
    Rake::Task['test:functionals'].invoke
    puts 'put 2'
    Rake::Task['test:functionals'].invoke
    puts 'put 3'
    
    #    Rake::Task['test'].invoke
    #    Rake::Task['spec'].invoke
    #    Rake::Task['cucumber'].invoke
  end
  
  ## FIXME: this generates an "Adminstrator links" card with the wrong reader_id, I have been
  ##  setting it by hand after fixture generation.
  desc "recreate test fixtures from fresh db"
  task :generate_fixtures => :environment do
    Rake::Task['wagn:reset_cache']
    # env gets auto-set to 'test' somehow.
    # but we need development to get the right schema dumped.
    ENV['RAILS_ENV'] = 'development'

    abcs = ActiveRecord::Base.configurations
    config = ENV['RAILS_ENV'] || 'development'
    olddb = abcs[config]["database"]
    abcs[config]["database"] = "wagn_test_template"

  #=begin
    begin
      # assume we have a good database, ie. just migrated dev db.
      puts "setting database to wagn_test_template"
      set_database 'wagn_test_template'
      Rake::Task['wagn:seed'].invoke

      # I spent waay to long trying to do this in a less hacky way--
      # Basically initial database setup/migration breaks your models and you really
      # need to start rails over to get things going again I tried ActiveRecord::Base.reset_subclasses etc. to no avail. -LWH
      puts ">>populating test data"
      puts `rake test:populate_template_database --trace`
      puts ">>extracting to fixtures"
      puts `rake test:extract_fixtures --trace`
    ensure
      set_database olddb
    end
    # go ahead and load the fixtures into the test database
    puts ">> preparing test database"
    puts `env RELOAD_TEST_DATA=true rake db:test:prepare --trace`
    
    Rake::Task['wagn:assume_card_migrations'].invoke
    
  end


  desc "dump current db to test fixtures"
  task :extract_fixtures => :environment do
    YAML::ENGINE.yamler = 'syck'
      # use old engine while we're supporting ruby 1.8.7 because it can't support Psych,
      # which dumps with slashes that syck can't understand (also !!null stuff)

    sql = "SELECT * FROM %s"
    tables = %w{ cards card_acts card_actions card_changes card_references }
    ActiveRecord::Base.establish_connection
    tables.each do |table_name|
      i = "000"
      File.open("#{Cardio.gem_root}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          record['trash'] = false if record.has_key? 'trash'
          record['draft'] = false if record.has_key? 'draft'
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end

  desc "create sample data for testing"
  task :populate_template_database => :environment do
    puts "populate test data\n"
    load "#{Cardio.gem_root}/test/seed.rb"
    SharedData.add_test_data
  end

end
