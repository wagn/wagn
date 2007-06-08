class InitialStructure < ActiveRecord::Migration
  def self.up
    create_table "system", :force => true do |t|
      t.column "password", :string, :limit => 60
    end
   
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

    create_table "nodes", :force => true do |t|
      t.column "type", :string
    end

    create_table "users", :force => true do |t|
      t.column "login", :string, :limit => 40
      t.column "email", :string, :limit => 100
      t.column "crypted_password", :string, :limit => 40
      t.column "salt", :string, :limit => 40
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "activated_at", :datetime
      t.column "activation_code", :string, :limit=>40
      t.column "invited_by", :integer, :null=>false
    end

    create_table "tags", :force => true do |t|
      t.column "name", :string, :default => "", :null => false
      t.column "node_id", :integer, :null => false
      t.column "node_type", :string, :null => false
    end
    add_index "tags", ["name"], :name => "tags_name_uniq", :unique => true
  
    create_table "tag_revisions", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "tag_id", :integer, :null => false
      t.column "created_by", :integer, :null => false
      t.column "name", :string, :null => false
      t.column "tag_type", :string, :null => false
    end
    add_foreign_key :tag_revisions, :tag_id, :tags
    add_foreign_key :tag_revisions, :created_by, :users
     
    create_table "pages", :force => true do |t|
      t.column "tag_id", :integer, :null => false
      t.column "parent_id", :integer
      t.column "created_at", :datetime, :null => false
      t.column "value", :string
      t.column "updated_at", :datetime, :null => false
      t.column "locked_by", :integer
      t.column "locked_at", :datetime
      t.column "web_id", :integer, :default => 0, :null => false
    end
    add_foreign_key :pages, :web_id, :webs
    add_foreign_key :pages, :locked_by, :users
    add_foreign_key(:pages,:tag_id, :tags)
    add_foreign_key(:pages, :parent_id, :pages)
  
    create_table "revisions", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "revised_at", :datetime, :null => false
      t.column "page_id", :integer, :null => false
      t.column "created_by", :integer, :null => false
      t.column "content", :text, :null => false
    end
    add_foreign_key :revisions, :page_id, :pages
    add_foreign_key :revisions, :created_by, :users
   
    create_table "wiki_files", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "web_id", :integer, :null => false
      t.column "file_name", :string, :null => false
      t.column "description", :string, :null => false
    end
    add_foreign_key :wiki_files, :web_id, :webs
  
    create_table "wiki_references", :force => true do |t|
      t.column "created_at", :datetime, :null => false
      t.column "updated_at", :datetime, :null => false
      t.column "page_id", :integer, :default => 0, :null => false
      t.column "referenced_name", :string, :limit => 60, :default => "", :null => false
      t.column "referenced_page_id", :integer
      t.column "link_type", :string, :limit => 1, :default => "", :null => false
    end
    add_foreign_key :wiki_references, :page_id, :pages
    add_foreign_key :wiki_references, :referenced_page_id, :pages

  end
  
  def self.down
    drop_table "system"
    drop_table "webs"
    drop_table "nodes"
    drop_table "users"
    drop_table "tags"
    drop_table "tag_revisions"
    drop_table "pages"
    drop_table "revisions"
    drop_table "wiki_files"
    drop_table "wiki_references"
  end
end
