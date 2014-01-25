WAGN_BOOTSTRAP_TABLES = %w{ cards card_revisions card_references users }

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
    
    # inserts existing card migrations into schema_migrations_cards to avoid re-migrating
    Wagn::MigrationHelper.schema_mode :card do
      ActiveRecord::Schema.assume_migrated_upto_version Wagn::Version.schema(:cards), Wagn::MigrationHelper.card_migration_paths
    end
    
    if Rails.env == 'test'
      puts "loading test fixtures"
      Rake::Task['db:fixtures:load'].invoke
    else
      puts "loading bootstrap"
      Rake::Task['wagn:bootstrap:load'].invoke
    end
  end
  
  
  
  desc "install wagn configuration files"
  task :install do
    puts "wagn:install is deprecated in favor of 'wagn new'"
=begin    
    require 'erb'
    rails_root = File.expand_path('./') # must be run from rails root dir
    # not using Rails.root because this task is putting core files in place and
    # therefore should not load rails environment

    config_dir = File.join(rails_root, 'config')
    sample_dir = File.join(rails_root, 'config/samples')

    #File.expand_path('../boot', __FILE__)
    @engine = ( ENV['ENGINE'] || 'mysql' ).to_sym
    @mode = ( ENV['MODE'] || 'default' ).to_sym

    cp File.join(sample_dir, "wagn.yml"), File.join(config_dir)

    if @mode==:dev
      cp File.join(sample_dir, "cucumber.yml"), File.join(config_dir)
    end

    dbfile = File.read File.join(sample_dir, 'database.yml.erb')

    File.open File.join(config_dir, 'database.yml'), 'w' do |file|
      file.write ERB.new(dbfile).result(binding)
    end
=end
  end
  
  desc "reset cache"
  task :reset_cache => :environment  do
    Wagn::Cache.reset_global
  end


  desc "migrate structure and cards"
  task :migrate =>:environment do
    stamp = ENV['STAMP_MIGRATIONS']

    puts 'migrating structure'
    Rake::Task['db:migrate'].invoke
    if stamp
      Rake::Task['wagn:migrate:stamp'].invoke ''
    end
    
    puts 'migrating cards'
    Rake::Task['wagn:migrate:cards'].execute #not invoke because we don't want to reload environment
    if stamp
      Rake::Task['wagn:migrate:stamp'].reenable
      Rake::Task['wagn:migrate:stamp'].invoke '_cards'
    end
    Wagn::Cache.reset_global
  end

  namespace :migrate do

    desc "migrate cards"
    task :cards => :environment do
      Wagn::Cache.reset_global
      Wagn::Conf[:migration] = true
      Card # this is needed in production mode to insure core db structures are loaded before schema_mode is set
    
      paths = ActiveRecord::Migrator.migrations_paths = Wagn::MigrationHelper.card_migration_paths
    
      Wagn::MigrationHelper.schema_mode :card do
        ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
        ActiveRecord::Migrator.migrate paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      end
    end
  
    desc 'write the version to a file (not usually called directly)' #maybe we should move this to a method? 
    task :stamp, :suffix do |t, args|
      Wagn::Conf[:migration] = true
      
      stamp_file = Wagn::Version.schema_stamp_path args[:suffix]
      Wagn::MigrationHelper.schema_mode args[:suffix ] do
        version = ActiveRecord::Migrator.current_version
        puts ">>  writing version: #{version} to #{stamp_file}"
        if file = open(stamp_file, 'w')
          file.puts version
        end
      end
    end
  end

  desc "copy over .htaccess files useful in production mode"
  task :copy_htaccess do
    access_file = File.join(Rails.root, 'config/samples/asset_htaccess')

    %w{ files assets }.each do |dirname|
      dir = File.join Rails.public_path, dirname
      mkdir_p dir
      cp access_file, File.join( dir, '.htaccess' )
    end
  end


  namespace :bootstrap do
    desc "rid template of unneeded cards, revisions, and references"
    task :clean => :environment do
      Wagn::Cache.reset_global

      # Correct time and user stamps
      botid = Card::WagnBotID
      extra_sql = {
        :cards          =>", creator_id=#{botid}, updater_id=#{botid}",
        :card_revisions =>", creator_id=#{botid}"
      }
      WAGN_BOOTSTRAP_TABLES.each do |table|
        next if table == 'card_references'
        ActiveRecord::Base.connection.update("update #{table} set created_at=now() #{extra_sql[table.to_sym] || ''};")
      end

      # delete ignored cards
      Account.as_bot do
        if ignoramus = Card['*ignore']
          ignoramus.item_cards.each do |card|
            if card.account #have to get rid of revisions to delete account  
              #(could also directly delete cards "manually", but would need to delete all descendants manually, too)
              ActiveRecord::Base.connection.delete( "delete from card_revisions where card_id = #{card.id}" )
            end
            card.delete!
          end
        end
      end

      ActiveRecord::Base.connection.delete( "delete from cards where trash is true" )

      # delete unwanted rows ( will need to revise if we ever add db-level data integrity checks )
      ActiveRecord::Base.connection.delete( "delete from card_revisions where not exists " +
        "( select name from cards where current_revision_id = card_revisions.id )"
      )
      ActiveRecord::Base.connection.delete( "delete from card_references where" +
        " (referee_id is not null and not exists (select * from cards where cards.id = card_references.referee_id)) or " +
        " (           referer_id is not null and not exists (select * from cards where cards.id = card_references.referer_id));"
      )
      ActiveRecord::Base.connection.delete( "delete from users where id > 2" ) #leave only anon and wagn bot
      Wagn::Cache.reset_global
      
    end

    desc "dump db to bootstrap fixtures"
    task :dump => :environment do
      Wagn::Cache.reset_global
      
      Rake::Task['wagn:bootstrap:mod_files'].invoke
      
      YAML::ENGINE.yamler = 'syck'
      # use old engine while we're supporting ruby 1.8.7 because it can't support Psych,
      # which dumps with slashes that syck can't understand
      
      WAGN_BOOTSTRAP_TABLES.each do |table|
        i = "000"
        File.open("#{Rails.root}/db/bootstrap/#{table}.yml", 'w') do |file|
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
    task :mod_files => :environment do
      template_files_dir = "#{Rails.root}/files"
      standard_files_dir = "#{Wagn.gem_root}/mods/standard/files"
      
      #FIXME - this should delete old revisions
      
      FileUtils.remove_dir standard_files_dir, force=true
      FileUtils.cp_r template_files_dir, standard_files_dir
      
      # add a fourth line to the raw content of each image (or file) to identify it as a mod file
      Card.search( :type=>['in', 'Image', 'File'], :ne=>'' ).each do |card|
        rev = Card::Revision.find card.current_revision_id
        rev.update_attributes :content=>rev.content + "\nstandard"        
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
