class KillPatternSpecKey < ActiveRecord::Migration
  def self.up
    begin
      remove_column :cards, :pattern_spec_key 
    rescue Exception => e
    end
  end

  def self.down
  end
end
