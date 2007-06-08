class RecentChangesAndViewings < ActiveRecord::Migration
  def self.up
    create_table "graveyard", :force=>true do |t|
      t.column "name", :string, :null=>false
      t.column "content", :string
      t.column "created_at", :datetime, :null=>false
    end

    create_table "recent_changes", :force=>true do |t|
      t.column "card_id", :integer
      t.column "name", :string
      t.column "action",     :string, :null=>false
      t.column "editor_id", :integer, :null=>false
      t.column "note", :string
      t.column "changed_at", :datetime, :null=>false
      t.column "grave_id", :integer
    end
    add_foreign_key :recent_changes, 'card_id', :cards
    add_foreign_key :recent_changes, 'editor_id', :users
    add_foreign_key :recent_changes, 'grave_id', :graveyard
    
    create_table "recent_viewings", :force=>true do |t|
      t.column "url",     :string, :null=>false
      t.column "card_id", :integer
      t.column "outcome",     :string, :null=>false
      t.column "viewer_id", :integer
      t.column "viewer_ip", :string
      t.column "viewed_at", :datetime, :null=>false
    end
    add_foreign_key :recent_viewings, 'card_id', :cards
    add_foreign_key :recent_viewings, 'viewer_id', :users
  end

  def self.down
    drop_table "recent_changes"
    drop_table "recent_viewings"
    drop_table "graveyard"
  end
end
