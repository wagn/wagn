
WAGN_BOOTSTRAP_TABLES = %w{ cards card_actions card_acts card_changes card_references }

namespace :wagn do
  desc "create a wagn database from scratch"
  task :create do
    puts "dropping"
    #fixme - this should be an option, but should not happen on standard creates!
    begin
      Rake::Task['db:drop'].invoke
    rescue
      puts "not dropped"
    end

    ENV['SCHEMA'] ||= "#{Wagn.gem_root}/db/schema.rb"
     
    puts "creating"
    Rake::Task['db:create'].invoke

    puts "loading schema"
    Rake::Task['db:schema:load'].invoke
    
    puts "update card_migrations"
    Rake::Task['wagn:assume_card_migrations'].invoke
    
    if Rails.env == 'test'
      puts "loading test fixtures"
      Rake::Task['db:fixtures:load'].invoke
    else
      puts "loading bootstrap"
      Rake::Task['wagn:bootstrap:load'].invoke
    end
    
    puts "set symlink for assets"
    Rake::Task['wagn:update_assets_symlink'].invoke
  end
  
  desc "update wagn gems and database"
  task :update do
    #system 'bundle update'
    if Wagn.paths["tmp"].existent
      FileUtils.rm_rf Wagn.paths["tmp"].first, :secure=>true
    end
    Dir.mkdir Wagn.paths["tmp"].first
    Rake::Task['wagn:migrate'].invoke
    # FIXME remove tmp dir / clear cache
    puts "set symlink for assets"
    Rake::Task['wagn:update_assets_symlink'].invoke
  end
  
  desc "reset cache"
  task :reset_cache => :environment  do
    Wagn::Cache.reset_global
  end

  desc "set symlink for assets"
  task :update_assets_symlink do
    if Rails.root.to_s != Wagn.gem_root and not File.exists? File.join(Rails.public_path, "assets")
      FileUtils.ln_s( Wagn.paths['gem-assets'].first, File.join(Rails.public_path, "assets") )
    end
  end

  desc "migrate structure and cards"
  task :migrate =>:environment do
    ENV['SCHEMA'] ||= "#{Wagn.gem_root}/db/schema.rb"
    
    stamp = ENV['STAMP_MIGRATIONS']

    puts 'migrating structure'
    Rake::Task['db:migrate'].invoke
    if stamp
      Rake::Task['wagn:migrate:stamp'].invoke :structure
    end
    
    puts 'migrating core cards'
    Wagn::Cache.reset_global
    Rake::Task['wagn:migrate:core_cards'].execute #not invoke because we don't want to reload environment
    if stamp
      Rake::Task['wagn:migrate:stamp'].reenable
      Rake::Task['wagn:migrate:stamp'].invoke :core_cards
    end
    
    puts 'migrating deck cards'
    Rake::Task['wagn:migrate:deck_cards'].execute #not invoke because we don't want to reload environment
    if stamp
      Rake::Task['wagn:migrate:stamp'].reenable
      Rake::Task['wagn:migrate:stamp'].invoke :deck_cards
    end
    
    Wagn::Cache.reset_global
  end

  desc 'insert existing card migrations into schema_migrations_cards to avoid re-migrating'
  task :assume_card_migrations do
    Wagn::Migration.schema_mode :card do
      ActiveRecord::Schema.assume_migrated_upto_version Wagn::Version.schema(:cards), Wagn::Migration.card_migration_paths
    end
  end

  namespace :migrate do
    desc "migrate cards" 
    task :cards => :environment do
      Rake::Task['wagn:migrate:core_cards'].invoke
      Rake::Task['wagn:migrate:deck_cards'].invoke
    end
    
    desc "migrate core cards"
    task :core_cards => :environment do
      Wagn::Cache.reset_global
      ENV['SCHEMA'] ||= "#{Wagn.gem_root}/db/schema.rb"
      Wagn.config.action_mailer.perform_deliveries = false
      Card.reset_column_information
      Card::Reference.reset_column_information
      
       # this is needed in production mode to insure core db structures are loaded before schema_mode is set
      
    
      paths = ActiveRecord::Migrator.migrations_paths = Wagn::Migration.paths(:core_cards)
    
      Wagn::Migration.schema_mode :core_cards do
        ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
        ActiveRecord::Migrator.migrate paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      end
    end
    
    desc "migrate deck cards"
    task :deck_cards => :environment do
      Wagn::Cache.reset_global
      ENV['SCHEMA'] ||= "#{Rails.root}/db/schema.rb"
      Wagn.config.action_mailer.perform_deliveries = false
      Card.reset_column_information # this is needed in production mode to insure core db structures are loaded before schema_mode is set
      Card::Reference.reset_column_information
    
      paths = ActiveRecord::Migrator.migrations_paths = Wagn::Migration.paths(:deck_cards)
    
      Wagn::Migration.schema_mode :deck_cards do
        ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
        ActiveRecord::Migrator.migrate paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      end
    end
  
    desc 'write the version to a file (not usually called directly)' #maybe we should move this to a method? 
    task :stamp, :type do |t, args|
      ENV['SCHEMA'] ||= "#{Wagn.gem_root}/db/schema.rb"
      Wagn.config.action_mailer.perform_deliveries = false
      
      stamp_file = Wagn::Version.schema_stamp_path( args[:type] )
      Wagn::Migration.schema_mode args[:type] do
        version = ActiveRecord::Migrator.current_version
        if version.to_i > 0 and file = open(stamp_file, 'w')
          puts ">>  writing version: #{version} to #{stamp_file}"
          file.puts version
        end
      end
    end
  end


  namespace :emergency do
    task :rescue_watchers => :environment do
      follower_hash = Hash.new { |h, v| h[v] = [] } 
      
      Card.where("right_id" => 219).each do |watcher_list|
        watcher_list.include_set_modules
        if watcher_list.left
          watching = watcher_list.left.name
          watcher_list.item_names.each do |user|
            follower_hash[user] << watching
          end
        end
      end
      
      Card.search(:right=>{:codename=>"following"}).each do |following|
        Card::Auth.as_bot do
          following.update_attributes! :content=>''
        end
      end
      
      follower_hash.each do |user, items|
        if card=Card.fetch(user) and card.account
          Card::Auth.as(user) do
            following = card.fetch :trait=>"following", :new=>{}
            following.items = items
          end
        end
      end
    end
  end
  
  namespace :bootstrap do
    desc "rid template of unneeded cards, acts, actions, changes, and references"
    task :clean => :environment do
      Wagn::Cache.reset_global
      conn =  ActiveRecord::Base.connection
      # Correct time and user stamps
      card_sql =  "update cards set created_at=now(), creator_id=#{ Card::WagnBotID }"
      card_sql +=                 ",updated_at=now(), updater_id=#{ Card::WagnBotID }"
      conn.update card_sql
      act_sql =  "update card_acts set acted_at=now(), actor_id=#{ Card::WagnBotID }"
      conn.update act_sql

      Card::Auth.as_bot do
        # delete ignored cards
        
        if ignoramus = Card['*ignore']
          ignoramus.item_cards.each do |card|
            card.delete!
          end
        end
        Wagn::Cache.reset_global
        %w{ machine_input machine_output }.each do |codename|
          Card.search(:right=>{:codename=>codename }).each do |card|
            FileUtils.rm_rf File.join('files', card.id.to_s ), :secure=>true            
            card.delete!
          end
        end
      end

      conn.delete( "delete from cards where trash is true" )

      Card::Action.delete_cardless
      Card::Action.delete_old
      Card::Change.delete_actionless


      act = Card::Act.create!(:actor_id=>Card::WagnBotID,
       :card_id=>Card::WagnBotID)
      Card::Action.find_each do |action|
        action.update_attributes!(:card_act_id=>act.id)
      end
      Card::Act.where('id != ?',act.id).delete_all
      conn.delete( "delete from card_references where" +
        " (referee_id is not null and not exists (select * from cards where cards.id = card_references.referee_id)) or " +
        " (           referer_id is not null and not exists (select * from cards where cards.id = card_references.referer_id));"
      )
      
      conn.delete( "delete from sessions" )
      
      Wagn::Cache.reset_global
      
    end

    desc "dump db to bootstrap fixtures"
    task :dump => :environment do
      Wagn::Cache.reset_global
      
      Rake::Task['wagn:bootstrap:copy_mod_files'].invoke
      
      YAML::ENGINE.yamler = 'syck'
      # use old engine while we're supporting ruby 1.8.7 because it can't support Psych,
      # which dumps with slashes that syck can't understand
      
      WAGN_BOOTSTRAP_TABLES.each do |table|
        i = "000"
        File.open("#{Wagn.gem_root}/db/bootstrap/#{table}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all( "select * from #{table}" )
          file.write YAML::dump( data.inject({}) do |hash, record|
            record['trash'] = false if record.has_key? 'trash'
            if record.has_key? 'content'
              record['content'] = record['content'].gsub /\u00A0/, '&nbsp;'
              # sych was handling nonbreaking spaces oddly.  would not be needed with psych.
            end
            hash["#{table}_#{i.succ!}"] = record
            hash
          end)
        end
      end
      
    end

    desc "copy files from template database to standard mod and update cards"
    task :copy_mod_files => :environment do
      
      mod_name = '05_standard'
      template_files_dir = "#{Wagn.root}/files"
      standard_files_dir = "#{Wagn.gem_root}/mod/#{mod_name}/file"
      
      FileUtils.remove_dir standard_files_dir, force=true
      FileUtils.cp_r template_files_dir, standard_files_dir

      # add a fourth line to the raw content of each image (or file) to identify it as a mod file      
      Card::Auth.as_bot do
        Card.search( :type=>['in', 'Image', 'File'], :ne=>'' ).each do |card|
          unless card.db_content.split(/\n/).last == mod_name
            new_content = card.db_content + "\n#{mod_name}"
            card.update_column :db_content, new_content
            card.last_action.change_for(2).first.update_column :value, new_content
            #FIXME - should technically update the change as well...
          end
        end
      end
    end


    desc "load bootstrap fixtures into db"
    task :load => :environment do
      #FIXME - shouldn't we be more standard and use seed.rb for this code?
      Rake.application.options.trace = true
      puts "bootstrap load starting"
      require 'active_record/fixtures'
#      require 'time'

      ActiveRecord::Fixtures.create_fixtures File.join( Wagn.gem_root, 'db/bootstrap'), WAGN_BOOTSTRAP_TABLES

    end
  end

end
