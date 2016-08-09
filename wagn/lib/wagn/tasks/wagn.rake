require "wagn/application"

WAGN_SEED_TABLES = %w( cards card_actions card_acts card_changes
                       card_references ).freeze
WAGN_SEED_PATH = File.join(
  ENV["DECKO_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "new"
)

def run_card_migration core_or_deck
  prepare_migration
  verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
  Cardio.schema_mode(core_or_deck) do |paths|
    ActiveRecord::Migrator.migrations_paths = paths
    ActiveRecord::Migration.verbose = verbose
    ActiveRecord::Migrator.migrate paths, version
  end
end

def prepare_migration
  Card::Cache.reset_all
  ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
  Card::Cache.reset_all
  Card.config.action_mailer.perform_deliveries = false
  Card.reset_column_information
  # this is needed in production mode to insure core db
  Card::Reference.reset_column_information
  # structures are loaded before schema_mode is set
end

namespace :wagn do
  desc "create a wagn database from scratch, load initial data"
  task :seed do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
    puts "dropping"
    # FIXME: this should be an option, but should not happen on standard
    # creates!
    begin
      Rake::Task["db:drop"].invoke
    rescue
      puts "not dropped"
    end

    puts "creating"
    Rake::Task["db:create"].invoke

    puts "loading schema"
    Rake::Task["db:schema:load"].invoke

    Rake::Task["wagn:load"].invoke
  end

  desc "clear and load fixtures with existing tables"
  task :reseed do
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    Rake::Task["wagn:clear"].invoke

    Rake::Task["wagn:load"].invoke
  end

  desc "empty the card tables"
  task :clear do
    conn = ActiveRecord::Base.connection

    puts "delete all data in bootstrap tables"
    WAGN_SEED_TABLES.each do |table|
      conn.delete "delete from #{table}"
    end
  end

  desc "Load bootstrap data into database"
  task :load do
    require "decko/engine"
    puts "update card_migrations"
    Rake::Task["wagn:assume_card_migrations"].invoke

    if Rails.env == "test" && !ENV["GENERATE_FIXTURES"]
      puts "loading test fixtures"
      Rake::Task["db:fixtures:load"].invoke
    else
      puts "loading bootstrap"
      Rake::Task["wagn:bootstrap:load"].invoke
    end

    puts "set symlink for assets"
    Rake::Task["wagn:update_assets_symlink"].invoke

    puts "reset cache"
    system "bundle exec rake wagn:reset_cache" # needs loaded environment
  end

  desc "update wagn gems and database"
  task :update do
    ENV["NO_RAILS_CACHE"] = "true"
    # system 'bundle update'
    if Wagn.paths["tmp"].existent
      FileUtils.rm_rf Wagn.paths["tmp"].first, secure: true
    end
    Dir.mkdir Wagn.paths["tmp"].first
    Rake::Task["wagn:migrate"].invoke
    # FIXME: remove tmp dir / clear cache
    puts "set symlink for assets"
    Rake::Task["wagn:update_assets_symlink"].invoke
  end

  desc "reset cache"
  task reset_cache: :environment do
    Card::Cache.reset_all
  end

  desc "set symlink for assets"
  task :update_assets_symlink do
    assets_path = File.join(Rails.public_path, "assets")
    if Rails.root.to_s != Wagn.gem_root && !File.exist?(assets_path)
      FileUtils.rm assets_path if File.symlink? assets_path
      FileUtils.ln_s(Decko::Engine.paths["gem-assets"].first, assets_path)
    end
  end

  desc "migrate structure and cards"
  task migrate: :environment do
    ENV["NO_RAILS_CACHE"] = "true"
    ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"

    stamp = ENV["STAMP_MIGRATIONS"]

    puts "migrating structure"
    Rake::Task["wagn:migrate:structure"].invoke
    Rake::Task["wagn:migrate:stamp"].invoke :structure if stamp

    puts "migrating core cards"
    Card::Cache.reset_all
    # not invoke because we don't want to reload environment
    Rake::Task["wagn:migrate:core_cards"].execute
    if stamp
      Rake::Task["wagn:migrate:stamp"].reenable
      Rake::Task["wagn:migrate:stamp"].invoke :core_cards
    end

    puts "migrating deck cards"
    # not invoke because we don't want to reload environment
    Rake::Task["wagn:migrate:deck_cards"].execute
    if stamp
      Rake::Task["wagn:migrate:stamp"].reenable
      Rake::Task["wagn:migrate:stamp"].invoke :deck_cards
    end

    Card::Cache.reset_all
  end

  desc "insert existing card migrations into schema_migrations_cards to avoid re-migrating"
  task :assume_card_migrations do
    require "decko/engine"

    Cardio.assume_migrated_upto_version :core_cards
  end

  namespace :migrate do
    desc "migrate cards"
    task cards: [:core_cards, :deck_cards]

    desc "migrate structure"
    task structure: :environment do
      ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
      Cardio.schema_mode(:structure) do |paths|
        ActiveRecord::Migrator.migrations_paths = paths
        ActiveRecord::Migrator.migrate paths, version
        Rake::Task["db:_dump"].invoke   # write schema.rb
      end
    end

    desc "migrate core cards"
    task core_cards: :environment do
      require "card/core_migration"
      run_card_migration :core_cards
    end

    desc "migrate deck cards"
    task deck_cards: :environment do
      require "card/migration"
      run_card_migration :deck_cards
    end

    desc 'Runs the "up" for a given deck cards migration VERSION.'
    task up: :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      raise "VERSION is required" unless version
      ActiveRecord::Migration.verbose = verbose
      ActiveRecord::Migrator.run :up, Cardio.migration_paths(:deck_cards),
                                 version
    end

    # maybe we should move this to a method?
    desc "write the version to a file (not usually called directly)"
    task :stamp, :type do |_t, args|
      ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
      Cardio.config.action_mailer.perform_deliveries = false

      stamp_file = Cardio.schema_stamp_path(args[:type])

      Cardio.schema_mode args[:type] do
        version = ActiveRecord::Migrator.current_version
        if version.to_i > 0 && (file = open(stamp_file, "w"))
          puts ">>  writing version: #{version} to #{stamp_file}"
          file.puts version
        end
      end
    end
  end

  namespace :emergency do
    task rescue_watchers: :environment do
      follower_hash = Hash.new { |h, v| h[v] = [] }

      Card.where("right_id" => 219).each do |watcher_list|
        watcher_list.include_set_modules
        next unless watcher_list.left
        watching = watcher_list.left.name
        watcher_list.item_names.each do |user|
          follower_hash[user] << watching
        end
      end

      Card.search(right: { codename: "following" }).each do |following|
        Card::Auth.as_bot do
          following.update_attributes! content: ""
        end
      end

      follower_hash.each do |user, items|
        next unless (card = Card.fetch(user)) && card.account
        Card::Auth.as(user) do
          following = card.fetch trait: "following", new: {}
          following.items = items
        end
      end
    end
  end

  namespace :bootstrap do
    desc "rid template of unneeded cards, acts, actions, changes, and references"
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
      source_files_dir = "#{Wagn.root}/files"

      # mark mod files as mod files
      Card::Auth.as_bot do
        Card.search(type: %w(in Image File), ne: "").each do |card|
          if card.mod_file? || card.codename == "new_file" ||
             card.codename == "new_image"
            puts "skipping #{card.name}: already in code"
            next
          else
            puts "working on #{card.name}"
          end

          raise "need codename for file" unless card.codename.present?

          files = { original: card.attachment.path }
          card.attachment.versions.each_key do |version|
            files[version] = card.attachment.path(version)
          end

          # make card a mod file card
          mod_name = if (l = card.left) && l.type_id == Card::SkinID
                       "06_bootstrap"
                     else
                       "05_standard"
                     end
          card.update_column :db_content,
                             card.attachment.db_content(mod: mod_name)
          card.last_action.change(:content)
              .update_column :value, card.attachment.db_content(mod: mod_name)
          card.expire
          card = Card.fetch card.name

          target_dir = card.store_dir

          files.each do |version, path|
            FileUtils.cp path, card.attachment.path(version)
          end
        end
      end
    end

    desc "load bootstrap fixtures into db"
    task load: :environment do
      # FIXME: shouldn't we be more standard and use seed.rb for this code?
      Rake.application.options.trace = true
      puts "bootstrap load starting #{WAGN_SEED_PATH}"
      require "active_record/fixtures"
      ActiveRecord::FixtureSet.create_fixtures WAGN_SEED_PATH, WAGN_SEED_TABLES
    end
  end
end

def correct_time_and_user_stamps
  conn = ActiveRecord::Base.connection
  who_and_when = [Card::WagnBotID, Time.now.utc.to_s(:db)]
  card_sql = "update cards set creator_id=%1$s, created_at='%2$s', updater_id=%1$s, updated_at='%2$s'"
  conn.update(card_sql                                          % who_and_when)
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

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
