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
      #ENV['BOOTSTRAP_DUMP'] = 'true'
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
      ENV['BOOTSTRAP_LOAD'] = 'true'
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
      
    
      role_ids = {}
      Role.find(:all).each do |role|
        role_ids[role.codename.to_sym] = role.id
      end

      Wagn::Cache.initialize_on_startup
      Card.cache.reset if Card.cache  #necessary?
      User.current_user = :wagbot

      perm_rules = {
        '*all' => { :create=>:auth, :read=>:anon, :update => :auth, :delete => :auth, :comment=>nil },
        '*all plus' => { :create=>:left, :read=>:left, :update => :left, :delete => :left },
        '*star'                 => { :create=>:admin, :update => :admin, :delete => :admin },
        '*rstar'                => { :create=>:admin, :update => :admin, :delete => :admin },
        '*watcher+*right'       => { :create=>:auth,  :update => :auth  },
        'Role+*type'            => { :create=>:admin },
        'Html+*type'            => { :create=>:admin },
        'Account Request+*type' => { :create=>:anon  },
        'discussion+*right'     => { :comment=>:anon },
        'Administrator links+*self'=> { :read=>:admin },
      }

      puts 'creating permission cards'
      perm_rules.each_key do |set|
        perm_rules[set].each_key do |setting|
          val = perm_rules[set][setting]
          role_card = nil
          content = case val
            when :left  ;  '_left'
            when nil    ;  ''
            else
              role_card = Role[val].card if val
              "[[#{role_card.name}]]"
            end
          c = Card.create! :name=> "#{set}+*#{setting}", :typecode=> 'Pointer', :content=>content
          if role_card
            WikiReference.create(
              :card_id=>c.id, 
              :referenced_name=>role_card.key,
              :referenced_card_id=>role_card.id,
              :link_type => 'L' 
            )
          end
        end
      end
      Card.cache.reset if Card.cache
      
      puts 'updating read_rule fields'
      Card.find(:all).each do |card|
        card.update_read_rule
      end
      ENV['BOOTSTRAP_LOAD'] = 'false'
    end
  end
end


