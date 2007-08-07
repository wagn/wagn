class AddAppender < ActiveRecord::Migration
  def self.up
    add_column :cards, :appender_type, :string, :null=>true
    add_column :cards, :appender_id, :integer, :null=>true
  end

  def self.down
    remove_column :cards, :appender_type
    remove_column :cards, :appender_id
  end
end
