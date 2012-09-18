
WAGN_BOOTSTRAP_TABLES = %w{ cards card_revisions card_references }

namespace :wagn do

  desc "create a wagn database from scratch"
  task :create do
    puts "dropping"
    begin
      Rake::Task['db:drop'].invoke
    rescue
      puts "not dropped"
    end
    
    puts "creating"
    Rake::Task['db:create'].invoke

    puts "loading schema"
    Rake::Task['db:schema:load'].invoke
    
    if Rails.env == 'test'
      puts "loading test fixtures"
      Rake::Task['db:fixtures:load'].invoke
    else
      puts "loading bootstrap"
      Rake::Task['wagn:bootstrap:load'].invoke
    end
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
      
      WAGN_BOOTSTRAP_TABLES.each do |table|
        i = "000"
        File.open("#{Rails.root}/db/bootstrap/#{table}.yml", 'w') do |file|
          data = 
            if table=='cards'
              Session.as_bot do
                Card.search({:not=>{:referred_to_by=>'*ignore'}}).map &:attributes
              end
            else
              sql = (table=='card_revisions' ?
                #FIXME -- still getting ignored content in revisions / references.
                # should probably clean database first then do simple dump
                'select r.* from %s r join cards c on c.current_revision_id = r.id' :
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
      Rake.application.options.trace = true
      puts "bootstrap load starting"
      require 'active_record/fixtures'                         
      require 'time'

      ActiveRecord::Fixtures.create_fixtures 'db/bootstrap', WAGN_BOOTSTRAP_TABLES + %w{ users}
      # note: users table is hand-coded, not dumped
    
      # Correct time and user stamps
      extra_sql = { :cards =>',created_by=1, updated_by=1',  :card_revisions=>',created_by=1' }
      now = Time.new.strftime("%Y-%m-%d %H:%M:%S")
      %w{ users cards card_references card_revisions }.each do |table|
        ActiveRecord::Base.connection.update("update #{table} set created_at='#{now}' #{extra_sql[table.to_sym] || ''};")
      end
    
      ActiveRecord::Base.connection.delete( "delete from card_references where" +
        " (referenced_card_id is not null and not exists (select * from cards where cards.id = card_references.referenced_card_id)) or " +
        " (           card_id is not null and not exists (select * from cards where cards.id = card_references.card_id));"
      )
    end
  end
end


