WAGN_BOOTSTRAP_TABLES = %w{ cards card_revisions card_references }
#note: users, roles, and role_users have been manually edited

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
    desc "rid template of unneeded cards, revisions, and references"
    task :clean => :environment do
      Wagn::Cache.reset_global

      # Correct time and user stamps
      botid = Card::WagnBotID
      extra_sql = {
        :cards          =>", creator_id=#{botid}, updater_id=#{botid}",
        :card_revisions =>", creator_id=#{botid}"
      }
      %w{ users cards card_references card_revisions }.each do |table|
        ActiveRecord::Base.connection.update("update #{table} set created_at=now() #{extra_sql[table.to_sym] || ''};")
      end

      # trash ignored cards
      Session.as_bot do
        Card.search( {:referred_to_by=>'*ignore'} ).each do |card|
          card.destroy!
        end
      end

      # delete unwanted rows ( will need to revise if we ever add db-level data integrity checks )
      ActiveRecord::Base.connection.delete( "delete from cards where trash is true" )
      ActiveRecord::Base.connection.delete( "delete from card_revisions where not exists " +
        "( select name from cards where current_revision_id = card_revisions.id )"
      )
      ActiveRecord::Base.connection.delete( "delete from card_references where" +
        " (referenced_card_id is not null and not exists (select * from cards where cards.id = card_references.referenced_card_id)) or " +
        " (           card_id is not null and not exists (select * from cards where cards.id = card_references.card_id));"
      )

    end

    desc "dump db to bootstrap fixtures"
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
          data = ActiveRecord::Base.connection.select_all( "select * from #{table}" )
          file.write YAML::dump( data.inject({}) { |hash, record|
            fail "UNTESTED CODE. pls make sure trash is actually showing up as false (not '0')\n....and pls REMOVE THIS MSG from bootstrap.rake!\n\n"
            hash['trash'] = false
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
#      require 'time'

      ActiveRecord::Fixtures.create_fixtures 'db/bootstrap', WAGN_BOOTSTRAP_TABLES << 'users'
      # note: users table is hand-coded, not dumped

    end
  end
end


