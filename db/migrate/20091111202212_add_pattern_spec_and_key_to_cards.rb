class AddPatternSpecAndKeyToCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :pattern_keys, :string
    add_column :cards, :pattern_spec_key, :string
  end

  def self.down
    remove_column :cards, :pattern_spec_key
    remove_column :cards, :pattern_keys
  end
end
