class StampFields < ActiveRecord::Migration
  def up
    change_column "cards", "creator_id", "integer", :null=>false
    change_column "cards", "updater_id", "integer", :null=>false
    change_column "card_revisions", "creator_id", "integer", :null=>false
  end

  def down
    change_column "cards", "creator_id", "integer", :null=>true
    change_column "cards", "updater_id", "integer", :null=>true
    change_column "card_revisions", "creator_id", "integer", :null=>true
  end
end
