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
  end

  desc "migrate cards"
  task :migrate_cards => :environment do
    rpaths = Rails.application.paths
    rpaths.add 'db/migrate_cards'
    paths = ActiveRecord::Migrator.migrations_paths = rpaths['db/migrate_cards'].to_a
    
    ActiveRecord::Base.table_name_suffix = '_cards'
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil
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

      # trash ignored cards
      Account.as_bot do
        Card.search( {:referred_to_by=>'*ignore'} ).each do |card|
          card.delete!
        end
      end


      # delete unwanted rows ( will need to revise if we ever add db-level data integrity checks )
      ActiveRecord::Base.connection.delete( "delete from cards where trash is true" )
      ActiveRecord::Base.connection.delete( "delete from card_revisions where not exists " +
        "( select name from cards where current_revision_id = card_revisions.id )"
      )
      ActiveRecord::Base.connection.delete( "delete from card_references where" +
        " (referee_id is not null and not exists (select * from cards where cards.id = card_references.referee_id)) or " +
        " (           referer_id is not null and not exists (select * from cards where cards.id = card_references.referer_id));"
      )
      ActiveRecord::Base.connection.delete( "delete from users where id > 2" ) #leave only anon and wagn bot
    end

    desc "dump db to bootstrap fixtures"
    task :dump => :environment do
      Wagn::Cache.reset_global
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


    desc "load bootstrap fixtures into db"
    task :load => :environment do
      Rake.application.options.trace = true
      puts "bootstrap load starting"
      require 'active_record/fixtures'
#      require 'time'

      ActiveRecord::Fixtures.create_fixtures 'db/bootstrap', WAGN_BOOTSTRAP_TABLES

    end
  end

end
