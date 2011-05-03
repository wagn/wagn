namespace :wagn do
  desc "(re) create a wagn database from scratch"
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
      require 'time'
      now = Time.new.strftime("%Y-%m-%d %H:%M:%S")
      %w{ users cards wiki_references revisions }.each do |table|
        ActiveRecord::Base.connection.update("update #{table} set created_at='#{now}', updated_at='#{now}' #{extra_sql[table.to_sym] || ''};")
      end
    
      #CLEAN UP wiki references.  NOTE, this might bust in mysql?  test!
      ActiveRecord::Base.connection.delete( "delete from wiki_references where" +
        " (referenced_card_id is not null and not exists (select * from cards where cards.id = wiki_references.referenced_card_id)) or " +
        " (           card_id is not null and not exists (select * from cards where cards.id = wiki_references.card_id));"
      )

      #config_cards = %w{ *context *to *title account_request+*type+*content account_request+*type+*default *invite+*thank *signup+*thank *from }
      permset = (ENV['PERMISSIONS'] || :standard).to_sym
      
      permission = {
        :standard=>{
         :default=> {:read=>:anon, :edit=>:auth, :delete=>:auth, :create=>:auth, :comment=>nil},
         :star=> {:edit=>:admin, :delete=>:admin},
         '*all+*default' => {:edit=>:auth, :delete=>:auth},
         'role'=> {:create=>:admin},
         'html'=> {:create=>:admin},
         'account_request' => {:create=>:anon},
#         'account_request+*tform' {:read=>:admin},
         'administrator_link'=> {:read=>:admin},
         'discussion+*right+*default'=> {:comment=>:anon},
         '*watcher' => {:edit=>:auth},
         '*watcher+*right+*default' => {:edit=>:auth}
        },
        :openedit=>{
         :default=> {:read=>:anon, :edit=>:anon, :delete=>:auth, :create=>:anon, :comment=>nil},
         :star=> {:edit=>:admin, :delete=>:admin},
         'role'=> {:create=>:admin},
         'html'=> {:create=>:admin},
         'html+*type+*default'=> {:edit=>:admin},
         'administrator_link'=> {:read=>:admin},
         'discussion+*right+*default'=> {:comment=>:anon},
         '*watcher' => {:edit=>:auth},
         '*watcher+*right+*default' => {:edit=>:auth}
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
        key = card['key']
        cardset = perms[key] || {}
        starset = (key =~ /^\*/ ? perms[:star] : {})
          
        default.keys.each do |ttask|
          next if ttask== :create and card['type'] != 'Cardtype'
          codename = cardset[ttask] || starset[ttask] || default[ttask]
          next unless codename
          party_id = role_ids[codename]
          
          ActiveRecord::Base.connection.update(
            "INSERT into permissions (card_id, task, party_type, party_id) "+
            "VALUES (#{card['id']}, '#{ttask}', 'Role', #{party_id} )"
          )
          if ttask== :read
            ActiveRecord::Base.connection.update(
              "UPDATE cards set reader_type='Role', reader_id=#{party_id} where id=#{card['id']}"
            )
          end
        end
      end

      Card.cache.reset if Card.cache  #this isn't working.  might need to reload more?
      

      User.current_user = :wagbot

      perm_rules = {
        '*all' => { :create=>:auth, :update => :auth, :edit=> :auth, :delete => :auth, :comment=>nil },
        'Role+*type'            => { :create=>:admin },
        'Html+*type'            => { :create=>:admin },
        'Account Request+*type' => { :create=>:anon  },
        'discussion+*right'     => { :comment=>:anon },
      }
      Rails.logger.info ('creating the bastards')
      perm_rules.each_key do |set|
        perm_rules[set].each_key do |setting|
          val = perm_rules[set][setting]
          c = Card.create!(
            :name=> "#{set}+*#{setting}",
            :type=> 'Pointer',
            :content=>(val.nil? ? '' : "#{[[Role[val].card.name]]}")
          )
          Rails.logger.info "saved #{c.name} with content #{c.content}"
        end
      end

    end
  end
end


