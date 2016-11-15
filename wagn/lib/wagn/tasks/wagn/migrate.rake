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
  namespace :migrate do
    desc "migrate cards"
    task cards: [:core_cards, :deck_cards]

    desc "migrate structure"
    task structure: :environment do
      ENV["SCHEMA"] ||= "#{Cardio.gem_root}/db/schema.rb"
      Cardio.schema_mode(:structure) do |paths|
        ActiveRecord::Migrator.migrations_paths = paths
        ActiveRecord::Migrator.migrate paths, version
        Rake::Task["db:_dump"].invoke # write schema.rb
      end
    end

    desc "migrate core cards"
    task core_cards: :environment do
      require "card/migration/core"
      run_card_migration :core_cards
    end

    desc "migrate deck cards"
    task deck_cards: :environment do
      require "card/migration"
      run_card_migration :deck_cards
    end

    desc "Redo the deck cards migration given by VERSION."
    task redo: :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      raise "VERSION is required" unless version
      ActiveRecord::Migration.verbose = verbose
      ActiveRecord::SchemaMigration.where(version: version.to_s).delete_all
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
end
