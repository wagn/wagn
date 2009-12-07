class AddSettingsToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :settings, :string
  end

  def self.down
    remove_column :cards, :settings
  end
end
