class MoreSpaceForDbContent < ActiveRecord::Migration
  def change
    change_column :cards, :db_content, :text, limit: 1.megabyte
  end
end
