require 'lib/util/card_builder.rb'      
 

task :populate_template_database => :environment do
  # setup test data here
  # admin and hoozebot are created in the migration
     
  ::User.as_admin do 
    puts "creating user cards"
    joe_user = ::User.create! :login=>"joe",:email=>'joe@test.org', :status => 'active', :password=>'joepass', :password_confirmation=>'joepass'
    joe_card = Card::User.create! :name=>"Joe User", :extension=>joe_user                                                                       
  end   
end


task :generate_fixtures => :environment do
  abcs = ActiveRecord::Base.configurations    
  config = RAILS_ENV || 'development'  
  olddb = abcs[config]["database"]
  abcs[config]["database"] = "wagn_test_template"

  Rake::Task['db:drop'].invoke
  Rake::Task['db:create'].invoke
  Rake::Task['db:migrate'].invoke         

  set_database 'wagn_test_template'
  # I spent waay to long trying to do this in a less hacky way--  
  # Basically initial database setup/migration breaks your models and you really 
  # need to start rails over to get things going again I tried ActiveRecord::Base.reset_subclasses etc. to no avail. -LWH
  puts `rake populate_template_database --trace`      
  puts `rake extract_fixtures`
  set_database olddb
end

task :extract_fixtures => :environment do
  sql = "SELECT * FROM %s"
  skip_tables = ["schema_info"]
  ActiveRecord::Base.establish_connection
  (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
    i = "000"
    File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
end                            
  
def set_database( db )
  y = YAML.load_file("#{RAILS_ROOT}/config/database.yml")
  y["development"]["database"] = db
  y["production"]["database"] = db
  File.open( "#{RAILS_ROOT}/config/database.yml", 'w' ) do |out|
    YAML.dump( y, out )
  end
end
#end