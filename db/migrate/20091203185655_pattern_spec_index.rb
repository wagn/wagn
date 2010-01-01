class PatternSpecIndex < ActiveRecord::Migration
  def self.up
    add_index "cards", ["pattern_spec_key"]
  end

  def self.down
  end
end
