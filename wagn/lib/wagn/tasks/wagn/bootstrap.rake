namespace :wagn do
  namespace :bootstrap do
    desc "rid template of unneeded cards, acts, actions, changes, " \
         "and references"
    task clean: :environment do
      Card::Cache.reset_all
      clear_history
      delete_unwanted_cards
      Card.empty_trash
      correct_time_and_user_stamps
      Card::Cache.reset_all
    end

    desc "dump db to bootstrap fixtures"
    task dump: :environment do
      Card::Cache.reset_all

      # FIXME: temporarily taking this out!!
      Rake::Task["wagn:bootstrap:copy_mod_files"].invoke
      Card[:all, :script].make_machine_output_coded
      Card[:all, :style].make_machine_output_coded
      Card[:script_html5shiv_printshiv].make_machine_output_coded

      YAML::ENGINE.yamler = "syck" if RUBY_VERSION !~ /^(2|1\.9)/
      # use old engine while we're supporting ruby 1.8.7 because it can't
      # support Psych, which dumps with slashes that syck can't understand

      WAGN_SEED_TABLES.each do |table|
        i = "000"
        File.open(File.join(WAGN_SEED_PATH, "#{table}.yml"), "w") do |file|
          data = ActiveRecord::Base.connection.select_all(
            "select * from #{table}"
          )
          file.write YAML.dump(data.each_with_object({}) do |record, hash|
            record["trash"] = false if record.key? "trash"
            record["draft"] = false if record.key? "draft"
            if record.key? "content"
              record["content"] = record["content"].gsub(/\u00A0/, "&nbsp;")
              # sych was handling nonbreaking spaces oddly.
              # would not be needed with psych.
            end
            hash["#{table}_#{i.succ!}"] = record
          end)
        end
      end
    end

    desc "copy files from template database to standard mod and update cards"
    task copy_mod_files: :environment do
      # mark mod files as mod files
      Card::Auth.as_bot do
        Card.search(type: %w(in Image File), ne: "").each do |card|
          if card.coded? || card.codename == "new_file" ||
             card.codename == "new_image"
            puts "skipping #{card.name}: already in code"
            next
          else
            puts "working on #{card.name}"
          end

          # make card a mod file card
          mod_name = if (l = card.left) && l.type_id == Card::SkinID
                       "bootstrap"
                     else
                       "standard"
                     end
          card.update_attributes! storage_type: :coded,
                                  mod: mod_name,
                                  empty_ok: true
        end
      end
    end

    desc "load bootstrap fixtures into db"
    task load: :environment do
      # FIXME: shouldn't we be more standard and use seed.rb for this code?
      Rake.application.options.trace = true
      puts "bootstrap load starting #{WAGN_SEED_PATH}"
      Rake::Task["db:seed"].invoke
    end
  end
end

def correct_time_and_user_stamps
  conn = ActiveRecord::Base.connection
  who_and_when = [Card::WagnBotID, Time.now.utc.to_s(:db)]
  card_sql = "update cards set creator_id=%1$s, created_at='%2$s', " \
             "updater_id=%1$s, updated_at='%2$s'"
  conn.update(card_sql % who_and_when)
  conn.update("update card_acts set actor_id=%s, acted_at='%s'" % who_and_when)
end

def delete_unwanted_cards
  Card::Auth.as_bot do
    if (ignoramus = Card["*ignore"])
      ignoramus.item_cards.each(&:delete!)
    end
    Card::Cache.reset_all
    # FIXME: can this be associated with the machine module somehow?
    %w(machine_input machine_output).each do |codename|
      Card.search(right: { codename: codename }).each do |card|
        FileUtils.rm_rf File.join("files", card.id.to_s), secure: true
        card.delete!
      end
    end
  end
end

def clear_history
  Card::Action.delete_old
  Card::Change.delete_actionless

  conn = ActiveRecord::Base.connection
  conn.execute("truncate card_acts")
  conn.execute("truncate sessions")
  act = Card::Act.create! actor_id: Card::WagnBotID,
                          card_id: Card::WagnBotID
  Card::Action.find_each do |action|
    action.update_attributes!(card_act_id: act.id)
  end
end
