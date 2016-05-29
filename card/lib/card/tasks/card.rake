namespace :card do
  desc 'merge import card data that was updated since the last push into the the database'
  task merge: :environment do
    Card::Migration::Import.merge
  end

  desc 'merge all import card data into the the database'
  task merge_all: :environment do
    Card::Migration::Import.merge true
  end

  desc 'add card to import data'
  task pull: :environment do
    _task, card = ARGV
    fail 'no card given' unless card.present?
    Card::Migration::Import.pull card, remote: ENV['from']
    exit
  end

  desc 'add card and all nested cards to import data'
  task deep_pull: :environment do
    _task, card = ARGV
    fail 'no card given' unless card.present?
    Card::Migration::Import.pull card, deep: true, remote: ENV['from']
    exit
  end

  desc 'add nested cards to import data (not the card itself)'
  task deep_pull_items: :environment do
    _task, card = ARGV
    fail 'no card given' unless card.present?
    Card::Migration::Import.pull card, items_only: true, remote: ENV['from']
    exit
  end

  desc 'add items of the export card to import data'
  task pull_export: :environment do
    Card::Migration::Import.pull 'export', items_only: true,
                                           remote: ENV['from']
  end

  desc 'register remote for importing card data'
  task add_remote: :environment do
    _task, name, url = ARGV
    fail 'no name given' unless name.present?
    fail 'no url given' unless url.present?
    Card::Migration::Import.add_remote name, url
    exit
  end
end
