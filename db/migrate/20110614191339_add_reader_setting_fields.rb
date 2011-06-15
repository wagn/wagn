class AddReaderSettingFields < ActiveRecord::Migration
  def self.up
    add_column :cards, :reader_key, :string
    add_column :cards, :reader_rule_id, :integer
  end

  def self.down
    drop_column :cards, :reader_key, :string
    drop_column :cards, :reader_rule_id, :integer
  end
end
