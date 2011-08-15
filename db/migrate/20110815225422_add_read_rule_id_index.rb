class AddReadRuleIdIndex < ActiveRecord::Migration
  def self.up
    add_index :cards, :read_rule_id
  end

  def self.down
    drop_index :cards, :read_rule_id
  end
end
