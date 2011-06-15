class AddReaderSettingFields < ActiveRecord::Migration
  def self.up
    add_column :cards, :read_rule_class, :string
    add_column :cards, :read_rule_id, :integer
  end

  def self.down
    remove_column :cards, :read_rule_class
    remove_column :cards, :read_rule_id
  end
end
