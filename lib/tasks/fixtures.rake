require File.expand_path(File.dirname(__FILE__) + '/../util/card_builder.rb')


 
def set_database( db )
  y = YAML.load_file("#{Rails.root.to_s}/config/database.yml")
  y["development"]["database"] = db
  y["production"]["database"] = db
  File.open( "#{Rails.root.to_s}/config/database.yml", 'w' ) do |out|
    YAML.dump( y, out )
  end
end

# desc 'Check for pending migrations and load the test schema'
# task :prepare => 'db:abort_if_pending_migrations' do
#   if defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?
#     Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:load" }[ActiveRecord::Base.schema_format]].invoke
#   end
# end

namespace :db do
  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(Rails.root.to_s, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        ActiveRecord::Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end  
    end
  end
end
        
namespace :test do                            
  ## FIXME: this generates an "Adminstrator links" card with the wrong reader_id, I have been 
  ##  setting it by hand after fixture generation.  
  desc "recreate test fixtures from fresh db"
  task :generate_fixtures => :environment do  
    Rake::Task['cache:clear']
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
      puts "migrating database #{olddb}"
      puts `echo $RAILS_ENV; rake db:migrate`
      puts "dumping schema"
      puts `rake db:schema:dump`
      puts "setting database to wagn_test_template"
      set_database 'wagn_test_template'
      # Rake::Task['db:drop'].invoke
      # Rake::Task['db:create'].invoke
      # Rake::Task['db:schema:load'].invoke
      # Rake::Task['wagn:bootstrap:load'].invoke
      puts "dropping database"
      puts `rake db:drop`
      puts "creating database"
      puts `rake db:create`
      puts "loading schema"
      puts `rake db:schema:load --trace`
      puts "loading bootstrap data"
      puts `rake wagn:bootstrap:load --trace`       
  
      # I spent waay to long trying to do this in a less hacky way--  
      # Basically initial database setup/migration breaks your models and you really 
      # need to start rails over to get things going again I tried ActiveRecord::Base.reset_subclasses etc. to no avail. -LWH
      puts ">>populating test data"
      puts `rake test:populate_template_database --trace`      
      puts ">>extracting to fixtures"
      puts `rake test:extract_fixtures --trace`
      set_database olddb 
    rescue Exception=>e
      warn "exception #{e.inspect} #{olddb}"
      set_database olddb 
      raise e
    end
    # go ahead and load the fixtures into the test database
    
    puts ">> preparing test database"
    puts `rake db:test:load --trace`
    puts ">> loading test fixtures"
    puts `rake db:fixtures:load RAILS_ENV=test --trace`
    
    #Rake::Task['db:test:prepare'].invoke
  #=end
  end

  desc "dump current db to test fixtures"
  task :extract_fixtures => :environment do
     YAML::ENGINE.yamler = 'syck'
      # use old engine while we're supporting ruby 1.8.7 because it can't support Psych, 
      # which dumps with slashes that syck can't understand (also !!null stuff)
      
    sql = "SELECT * FROM %s"
    skip_tables = ["schema_info","schema_migrations","sessions"]
    ActiveRecord::Base.establish_connection
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      i = "000"
      File.open("#{Rails.root.to_s}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
  
  desc "create sample data for testing"
  task :populate_template_database => :environment do        
    # setup test data here
    # additional test data auto-loaded from Test classes    
    # when I load these I don't want them to run as is the default; this is somewhat brutal..
              
    load 'test/seed.rb'
    SharedData.add_test_data

    ## FIXME: this was an attempt to automate loading data from the test files.
    #  I think it was maybe a little misguided.  anyway it breaks under rails 2.3 so 
    # not using it for now.
    
    #require 'test/unit'    
    #Test::Unit::AutoRunner.class_eval {  def self.run() 1 end }

    # Dir["#{Rails.root.to_s}/test/**/*.rb"].each {|f| load "#{f}"}  
    # ActiveSupport::TestCase.descendents.each do |c|
    #   if c.respond_to? :add_test_data 
    #     c.add_test_data
    #   end
    # end
  end
 
end
        

#end
