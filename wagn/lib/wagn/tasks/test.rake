TEST_SEED_PATH = File.join(
  ENV["DECKO_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "test"
)

namespace :test do
  task all: :environment do
    puts "This is not yet working; only first invocation takes effect"
    Rake::Task["test:functionals"].invoke
    puts "put 2"
    Rake::Task["test:functionals"].invoke
    puts "put 3"

    #    Rake::Task['test'].invoke
    #    Rake::Task['spec'].invoke
    #    Rake::Task['cucumber'].invoke
  end

  ## FIXME: this generates an "Adminstrator links" card with the wrong reader_id, I have been
  ##  setting it by hand after fixture generation.
  desc "recreate test fixtures from fresh db"
  task generate_fixtures: :environment do
    ENV["GENERATE_FIXTURES"] = "true"
    raise "must be test env" unless Rails.env == "test"

    Rake::Task["wagn:reset_cache"]

    puts "reseed test db"
    Rake::Task["wagn:seed"].invoke

    puts ">>populating test data"
    puts `rake test:populate_template_database --trace`

    puts ">>extracting to fixtures"
    puts `rake test:extract_fixtures --trace`
  end

  desc "dump current db to test fixtures"
  task extract_fixtures: :environment do
    raise "must be test env" unless Rails.env == "test"
    YAML::ENGINE.yamler = "syck" if RUBY_VERSION !~ /^(2|1\.9)/
    # use old engine while we're supporting ruby 1.8.7 because it can't support Psych,
    # which dumps with slashes that syck can't understand (also !!null stuff)

    sql = "SELECT * FROM %s"
    tables = %w(cards card_acts card_actions card_changes card_references)
    ActiveRecord::Base.establish_connection
    tables.each do |table_name|
      i = "000"
      File.open("#{TEST_SEED_PATH}/fixtures/#{table_name}.yml", "w") do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          record["trash"] = false if record.key? "trash"
          record["draft"] = false if record.key? "draft"
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end

  desc "create sample data for testing"
  task populate_template_database: :environment do
    raise "must be test env" unless Rails.env == "test"
    puts "populate test data\n"
    load "#{TEST_SEED_PATH}/seed.rb"
    SharedData.add_test_data
  end
end
