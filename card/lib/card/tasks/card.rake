namespace :card do
  desc "merge import card data that was updated since the last push into " \
       "the the database"
  task merge: :environment do
    Card::Migration::Import.merge
  end

  desc "merge all import card data into the the database"
  task merge_all: :environment do
    Card::Migration::Import.merge true
  end

  desc "add card to import data"
  task pull: :environment do
    pull_card
  end

  desc "add card and all nested cards to import data"
  task deep_pull: :environment do
    pull_card deep: true
  end

  desc "add nested cards to import data (not the card itself)"
  task deep_pull_items: :environment do
    pull_card items_only: true
  end

  desc "add items of the export card to import data"
  task pull_export: :environment do
    Card::Migration::Import.pull "export", items_only: true,
                                           remote: ENV["from"]
  end

  desc "add a new card to import data"
  task add: :environment do
    _task, name, type, codename = ARGV
    Card::Migration::Import.add_card name: name, type: type || "Basic",
                                     codename: codename
    exit
  end

  desc "register remote for importing card data"
  task add_remote: :environment do
    _task, name, url = ARGV
    raise "no name given" unless name.present?
    raise "no url given" unless url.present?
    Card::Migration::Import.add_remote name, url
    exit
  end

  def pull_card opts={}
    _task, card = ARGV
    raise "no card given" unless card.present?
    Card::Migration::Import.pull card, opts.merge(remote: ENV["from"])
    exit # without exit the card argument is treated as second rake task
  end
end
