namespace :wagn do
  require 'wagn/codename'
  Codename = Wagn::Codename

  desc "create a wagn database from scratch"
  task :create => :environment do
    puts "dropping"
    Rake::Task['db:drop'].invoke
    
    puts "creating"
    Rake::Task['db:create'].invoke

    puts "loading schema"
    Rake::Task['db:schema:load'].invoke
    
    puts "loading bootstrap"
    Rake::Task['wagn:bootstrap:load'].invoke
  end
  
  
  namespace :bootstrap do
  
    desc "dump db to bootstrap fixtures"
    #note: users, roles, and role_users have been manually edited
    task :dump => :environment do
      Wagn::Cache.reset_global
      begin
      YAML::ENGINE.yamler = 'syck'
      rescue
      end
      # use old engine while we're supporting ruby 1.8.7 because it can't support Psych, 
      # which dumps with slashes that syck can't understand
      
      %w{ cards revisions wiki_references codename users }.each do |table|
        i = "000"
        File.open("#{Rails.root}/db/bootstrap/#{table}.yml", 'w') do |file|
          data = 
            if table=='cards'
              User.as :wagbot do
                Card.search({:not=>{:referred_to_by=>'*ignore'}}).map &:attributes
              end
            else
              sql = (table=='revisions' ?
                'select r.*from %s r join cards c on c.current_revision_id = r.id' :
                'select * from %s'
              )
              ActiveRecord::Base.connection.select_all( sql % table)
            end
          file.write YAML::dump( data.inject({}) { |hash, record|
            hash["#{table}_#{i.succ!}"] = record
            hash
          })
        end
      end
    end
  
  
    desc "load bootstrap fixtures into db"
    task :load => :environment do
      Wagn::Cache.reset_global
      Rake.application.options.trace = true
      puts "bootstrap load starting"
      require 'active_record/fixtures'                         
      #ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      Dir.glob(File.join(Rails.root, 'db', 'bootstrap', '*.{yml,csv}')).each do |fixture_file|
        ActiveRecord::Fixtures.create_fixtures('db/bootstrap', File.basename(fixture_file, '.*'))
      end 
    
      extra_sql = { 
        :cards    =>',creator_id=1, updater_id=1',  
        :revisions=>',creator_id=1' 
      }
      require 'time'
      now = Time.new.strftime("%Y-%m-%d %H:%M:%S")
      %w{ users cards wiki_references revisions }.each do |table|
        ActiveRecord::Base.connection.update("update #{table} set created_at='#{now}' #{extra_sql[table.to_sym] || ''};")
      end
    
      #CLEAN UP wiki references.  NOTE, this might bust in mysql?  test!
      ActiveRecord::Base.connection.delete( "delete from wiki_references where" +
        " (referenced_card_id is not null and not exists (select * from cards where cards.id = wiki_references.referenced_card_id)) or " +
        " (           card_id is not null and not exists (select * from cards where cards.id = wiki_references.card_id));"
      )
    end
  end
end


