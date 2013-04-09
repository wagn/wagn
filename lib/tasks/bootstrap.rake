WAGN_BOOTSTRAP_TABLES = %w{ cards card_revisions card_references users }

namespace :wagn do
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


