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
      permset = (ENV['PERMISSIONS'] || :standard).to_sym
      
      permission = {
        :standard=>{
         :default=> {:read=>:anon, :edit=>:auth, :delete=>:auth, :create=>:auth, :comment=>nil},
         :star=> {:edit=>:admin, :delete=>:admin},
         'role'=> {:create=>:admin},
         'html'=> {:create=>:admin},
         'account_request' => {:create=>:anon},
#         'account_request+*tform' {:read=>:admin},
         'administrator_link'=> {:read=>:admin},
         'discussion+*rform'=> {:comment=>:anon},
         '*watcher' => {:edit=>:auth},
         '*watcher+*rform' => {:edit=>:auth}
        },
        :openedit=>{
         :default=> {:read=>:anon, :edit=>:anon, :delete=>:auth, :create=>:anon, :comment=>nil},
         :star=> {:edit=>:admin, :delete=>:admin},
         'role'=> {:create=>:admin},
         'html'=> {:create=>:admin},
         'html+*tform'=> {:edit=>:admin},
         'administrator_link'=> {:read=>:admin},
         'discussion+*rform'=> {:comment=>:anon},
         '*watcher' => {:edit=>:auth},
         '*watcher+*rform' => {:edit=>:auth}
        }
      } 
      
    
      role_ids = {}
      Role.find(:all).each do |role|
        role_ids[role.codename.to_sym] = role.id
      end

      perms = permission[permset]
      default = perms[:default]
    
      ActiveRecord::Base.connection.delete( 'delete from permissions')
      ActiveRecord::Base.connection.select_all( 'select * from cards' ).each do |card|
        #debugger if card.id == 15
        key = card['key']
        cardset = perms[key] || {}
        starset = (key =~ /^\*/ ? perms[:star] : {})
          
        default.keys.each do |task|
          next if task== :create and card['type'] != 'Cardtype'
          codename = cardset[task] || starset[task] || default[task]
          next unless codename
          party_id = role_ids[codename]
          
          ActiveRecord::Base.connection.update(
            "INSERT into permissions (card_id, task, party_type, party_id) "+
            "VALUES (#{card['id']}, '#{task}', 'Role', #{party_id} )"
          )
          if task== :read
            ActiveRecord::Base.connection.update(
              "UPDATE cards set reader_type='Role', reader_id=#{party_id} where id=#{card.id}"
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


