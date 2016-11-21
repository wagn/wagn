require "wagn/application"

WAGN_SEED_TABLES = %w( cards card_actions card_acts card_changes
                       card_references ).freeze
WAGN_SEED_PATH = File.join(
  ENV["DECKO_SEED_REPO_PATH"] || [Cardio.gem_root, "db", "seed"], "new"
)

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
  task reseed: :environment do
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
end

def version
  ENV["VERSION"] ? ENV["VERSION"].to_i : nil
end
