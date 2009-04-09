class RemoveSettingsTable < ActiveRecord::Migration
  def self.up
    drop_table :settings
  end

  def self.down
    create_table "settings", :force => true do |t|
      t.string "codename"
    end
  end
end
