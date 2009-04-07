namespace :wagn do
  
  task :create => :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    Rake::Task['db:schema:load'].invoke
    Rake::Task['wagn:bootstrap:load'].invoke
  end
  
  
  namespace :bootstrap do
  
    desc "dump db to bootstrap fixtures"
    #note: users, roles, and role_users have been manually edited
    task :dump => :environment do
      %w{ cards revisions wiki_references cardtypes }.each do |table|
        i = "000"
        File.open("#{RAILS_ROOT}/db/bootstrap/#{table}.yml", 'w') do |file|
          data = 
            if table=='cards'
              Card.search({:not=>{:referred_to_by=>'*ignore'}}).map &:attributes
            else
              sql = (table=='revisions' ?
                'select r.*from %s r join cards c on c.current_revision_id = r.id' :
                'select * from %s'
              )
              ActiveRecord::Base.connection.select_all( sql % table)
            end
          file.write data.inject({}) { |hash, record|
            hash["#{table}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  
  
    desc "load bootstrap fixtures into db"
    task :load => :environment do
      require 'active_record/fixtures'                         
      #ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      Dir.glob(File.join(RAILS_ROOT, 'db', 'bootstrap', '*.{yml,csv}')).each do |fixture_file|
        Fixtures.create_fixtures('db/bootstrap', File.basename(fixture_file, '.*'))
      end 
    
      extra_sql = { 
        :cards    =>',created_by=1, updated_by=1',  
        :revisions=>',created_by=1' 
      }
      %w{ users cards wiki_references revisions }.each do |table|
        ActiveRecord::Base.connection.update("update #{table} set created_at=now(), updated_at=now() #{extra_sql[table.to_sym] || ''};")
      end
    
      #CLEAN UP wiki references.  NOTE, this might bust in mysql?  test!
      ActiveRecord::Base.connection.delete( "delete from wiki_references where" +
        " (referenced_card_id is not null and not exists (select * from cards where cards.id = wiki_references.referenced_card_id)) or " +
        " (           card_id is not null and not exists (select * from cards where cards.id = wiki_references.card_id));"
      )

      config_cards = %w{ *context *to *title account_request+*tform *invite+*thank *signup+*thank *from }
      permset = :basic
      permission = {
        :basic=>{
          :read=> {:default=>:anon, 'administrator_link'=> :admin},
          :edit=> {:default=>:auth, 'administrator_link'=> :admin},
          :delete=>{:default=>:auth, 'administrator_link'=> :admin},
          :create=>{:default=>:auth, 'account_request'=>:anon},
          :comment=>{:default=>nil, 'discussion+*rform'=>:anon}
        }
      
      }
    
      role_ids = {}
      Role.find(:all).each do |role|
        role_ids[role.codename.to_sym] = role.id
      end
    
      ActiveRecord::Base.connection.delete( 'delete from permissions')
      ActiveRecord::Base.connection.select_all( 'select * from cards' ).each do |card|
        key = card['key']
        tasks = permission[:basic]
        tasks.keys.each do |task|
          perms = tasks[task]
          next if !perms[:default] and !perms[key]
          next if task== :create and card['type'] != 'Cardtype'
          party_id = role_ids[perms[key] || perms[:default]]
          ActiveRecord::Base.connection.update(
            "INSERT into permissions (card_id, task, party_type, party_id) "+
            "VALUES (#{card['id']}, '#{task}', 'Role', #{party_id} )"
          )
          if task== :read
            ActiveRecord::Base.connection.update(
              "UPDATE cards set reader_type='Role', reader_id=#{party_id}"
            )
          end
        end
      end

    end
    
  end
end
         
           
=begin    #
    # special cases:  
  
    discussion+*rform (comment)
    Account Request (create - anon?)
    HTML (create - anon) ??
    *to / *from (delete)
    *context, *to, *title, Account Request+*tform, *invite+*thanks, *signup+*thanks, *from (edit by admin)      
    Administrator links        
    # 

=end    


