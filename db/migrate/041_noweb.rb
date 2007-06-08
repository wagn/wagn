require_dependency 'db/card_creator.rb'

class Noweb < ActiveRecord::Migration
  class << self; include CardCreator; end
  
    
  def self.up
    if using_postgres?
      #execute %{ drop view card_summaries }
    end
    remove_column :cards, :web_id
    remove_column :wiki_files, :web_id
    drop_table :webs
  end

  def self.down
    create_table "webs", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "name", :string, :limit => 60, :default => "", :null => false
      t.column "address", :string, :limit => 60, :default => "", :null => false
      t.column "password", :string, :limit => 60
      t.column "additional_style", :string
      t.column "allow_uploads", :integer, :default => 1
      t.column "published", :integer, :default => 0
      t.column "count_pages", :integer, :default => 0
      t.column "markup", :string, :limit => 50, :default => "textile"
      t.column "color", :string, :limit => 6, :default => "008B26"
      t.column "max_upload_size", :integer, :default => 100
      t.column "safe_mode", :integer, :default => 0
      t.column "brackets_only", :integer, :default => 0
    end
    
    add_column :cards, :web_id, :integer
    add_column :wiki_files, :web_id, :integer
    
    MWeb.create(
      :name => 'wiki',
      :address => 'wiki'
    )
    execute %{ update cards set web_id=1 }
    execute %{ update wiki_files set web_id=1 }
    
  end
end
