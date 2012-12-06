# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121118114000) do

  create_table "card_references", :force => true do |t|
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "card_id",                         :default => 0,  :null => false
    t.string   "referenced_name",                 :default => "", :null => false
    t.integer  "referenced_card_id"
    t.string   "ref_type",           :limit => 1, :default => "", :null => false
    t.integer  "present"
  end

  add_index "card_references", ["card_id"], :name => "wiki_references_card_id"
  add_index "card_references", ["referenced_card_id"], :name => "wiki_references_referenced_card_id"
  add_index "card_references", ["referenced_name"], :name => "wiki_references_referenced_name"

  create_table "card_revisions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.integer  "card_id",    :null => false
    t.integer  "creator_id", :null => false
    t.text     "content",    :null => false
    t.integer  "created_by"
  end

  add_index "card_revisions", ["card_id"], :name => "revisions_card_id_index"
  add_index "card_revisions", ["creator_id"], :name => "revisions_created_by_index"

  create_table "cards", :force => true do |t|
    t.string   "name",                :null => false
    t.string   "key",                 :null => false
    t.string   "codename"
    t.string   "typecode"
    t.integer  "trunk_id"
    t.integer  "tag_id"
    t.integer  "current_revision_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "creator_id",          :null => false
    t.integer  "updater_id",          :null => false
    t.integer  "extension_id"
    t.string   "extension_type"
    t.text     "indexed_name"
    t.text     "indexed_content"
    t.string   "read_rule_class"
    t.integer  "read_rule_id"
    t.integer  "references_expired"
    t.boolean  "trash",               :null => false
    t.integer  "type_id",             :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "cards", ["extension_id", "extension_type"], :name => "cards_extension_index"
  add_index "cards", ["key"], :name => "cards_key_uniq", :unique => true
  add_index "cards", ["name"], :name => "cards_name_index"
  add_index "cards", ["read_rule_id"], :name => "index_cards_on_read_rule_id"
  add_index "cards", ["tag_id"], :name => "index_cards_on_tag_id"
  add_index "cards", ["trunk_id"], :name => "index_cards_on_trunk_id"
  add_index "cards", ["type_id"], :name => "card_type_index"

  create_table "cardtypes", :force => true do |t|
    t.string  "class_name"
    t.boolean "system"
    t.integer "card_id"
  end

  add_index "cardtypes", ["class_name"], :name => "cardtypes_class_name_uniq", :unique => true

  create_table "multihost_mappings", :force => true do |t|
    t.string   "requested_host"
    t.string   "canonical_host"
    t.string   "wagn_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "multihost_mappings", ["requested_host"], :name => "index_multihost_mappings_on_requested_host", :unique => true

  create_table "roles", :force => true do |t|
    t.string "codename"
    t.string "tasks"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "roles_users", ["role_id"], :name => "roles_users_role_id"
  add_index "roles_users", ["user_id"], :name => "roles_users_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "users", :force => true do |t|
    t.string   "login",               :limit => 40
    t.string   "email",               :limit => 100
    t.string   "crypted_password",    :limit => 40
    t.string   "salt",                :limit => 42
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_code", :limit => 40
    t.string   "status",                             :default => "request"
    t.integer  "invite_sender_id"
    t.string   "identity_url"
    t.integer  "card_id",                                                   :null => false
    t.integer  "account_id",                                                :null => false
  end

end
