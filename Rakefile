# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

#
namespace :db do
  namespace :test do
    desc 'Prepare the test database and load the schema'
    task :prepare => :environment do
      if defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?
        Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone" }[ActiveRecord::Base.schema_format]].invoke
      end 
      puts ">>loading test fixtures"
      puts `rake db:fixtures:load RAILS_ENV=test`
    end
  end
end

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
                  

                    
namespace :db do
  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end  
      Rake::Task['wagn:prepare_fulltext'].invoke
    end
  end
end
                
