require 'lib/util/card_builder.rb'      
 

task :populate_template_database => :environment do
  # setup test data here
  # admin and hoozebot are created in the migration
  # These are the cards that are present in basic installation before test data is added:
  #
  #        name         |   type   
  #---------------------+----------
  # Wagn                | Basic
  # Basic               | Cardtype
  # User                | Cardtype
  # Cardtype            | Cardtype
  # Role                | Cardtype
  # InvitationRequest   | Cardtype
  # Anyone              | Role    
  # Administrative User | Role
  # Anyone signed in    | Role
  # Wagn Bot            | User
  # Admin               | User
     
  ::User.as_admin do 

    # generic, shared user
    joe_user = ::User.create! :login=>"joe_user",:email=>'joe@user.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass', :invite_sender=>User.find_by_login('admin')
    joe_card = Card::User.create! :name=>"Joe User", :extension=>joe_user    
                          
    # generic, shared attribute card
    color = Card::Basic.create! :name=>"color"
    basic = Card::Basic.create! :name=>"basic card"  
                                    
    # data for testing users and invitation requests 
    ron_request = Card::InvitationRequest.create! :name=>"Ron Request", :email=>"ron@request.com"  
    no_count = Card::User.create! :name=>"No Count", :content=>"I got not account"

    # data for role_test.rb
    u1 = ::User.create! :login=>"u1",:email=>'u1@user.com', :status => 'active', :password=>'u1_pass', :password_confirmation=>'u1_pass', :invite_sender=>User.find_by_login('admin')
    u2 = ::User.create! :login=>"u2",:email=>'u2@user.com', :status => 'active', :password=>'u2_pass', :password_confirmation=>'u2_pass', :invite_sender=>User.find_by_login('admin')
    u3 = ::User.create! :login=>"u3",:email=>'u3@user.com', :status => 'active', :password=>'u3_pass', :password_confirmation=>'u3_pass', :invite_sender=>User.find_by_login('admin')

    r1 = Card::Role.create!( :name=>'r1' ).extension
    r2 = Card::Role.create!( :name=>'r2' ).extension
    r3 = Card::Role.create!( :name=>'r3' ).extension
    r4 = Card::Role.create!( :name=>'r4' ).extension
    
    r1.users = [ u1, u2, u3 ]
    r2.users = [ u1, u2 ]
    r3.users = [ u1 ]
    r4.users = [ u3, u2 ]
    
    c1 = Card.create :name=>'c1'
    c2 = Card.create :name=>'c2'
    c3 = Card.create :name=>'c3'
    
                 
  end   
  
  #::User.as( ::User.find_by_login('anonymous'))) do 
  #  Card::InvitationRequest
  #end
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
  
  # go ahead and load the fixtures into the test database
  Rake::Task['db:test:prepare'].invoke
  puts `env RAILS_ENV=test rake db:fixtures:load`
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