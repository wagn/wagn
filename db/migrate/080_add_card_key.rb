class AddCardKey < ActiveRecord::Migration
  def self.up
    add_column :cards, :key, :string
    MCard.reset_column_information
    MCard.find(:all).each do |card|
      card.key = card.name.to_key
      puts "Setting key: #{card.name} -> #{card.key}"
      card.save!
    end
  end

  def self.down
    remove_column :cards, :key
  end
end
