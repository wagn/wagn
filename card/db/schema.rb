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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151105225559) do

  create_table "card_actions", force: :cascade do |t|
    t.integer "card_id",         limit: 4
    t.integer "card_act_id",     limit: 4
    t.integer "super_action_id", limit: 4
    t.integer "action_type",     limit: 4
    t.boolean "draft"
    t.text    "comment",         limit: 65535
  end

  add_index "card_actions", ["card_act_id"], name: "card_actions_card_act_id_index", using: :btree
  add_index "card_actions", ["card_id"], name: "card_actions_card_id_index", using: :btree

  create_table "card_acts", force: :cascade do |t|
    t.integer  "card_id",    limit: 4
    t.integer  "actor_id",   limit: 4
    t.datetime "acted_at"
    t.string   "ip_address", limit: 255
  end

  add_index "card_acts", ["actor_id"], name: "card_acts_actor_id_index", using: :btree
  add_index "card_acts", ["card_id"], name: "card_acts_card_id_index", using: :btree

  create_table "card_changes", force: :cascade do |t|
    t.integer "card_action_id", limit: 4
    t.integer "field",          limit: 4
    t.text    "value",          limit: 16777215
  end

  add_index "card_changes", ["card_action_id"], name: "card_changes_card_action_id_index", using: :btree

  create_table "card_references", force: :cascade do |t|
    t.integer "referer_id",  limit: 4,   default: 0,  null: false
    t.string  "referee_key", limit: 255, default: "", null: false
    t.integer "referee_id",  limit: 4
    t.string  "ref_type",    limit: 1,   default: "", null: false
    t.integer "present",     limit: 4
  end

  add_index "card_references", ["referee_id"], name: "card_references_referee_id_index", using: :btree
  add_index "card_references", ["referee_key"], name: "card_references_referee_key_index", using: :btree
  add_index "card_references", ["referer_id"], name: "card_references_referer_id_index", using: :btree

  create_table "card_revisions", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.integer  "card_id",    limit: 4,     null: false
    t.integer  "creator_id", limit: 4,     null: false
    t.text     "content",    limit: 65535, null: false
  end

  add_index "card_revisions", ["card_id"], name: "revisions_card_id_index", using: :btree
  add_index "card_revisions", ["creator_id"], name: "revisions_created_by_index", using: :btree

  create_table "cards", force: :cascade do |t|
    t.string   "name",                limit: 255,      null: false
    t.string   "key",                 limit: 255,      null: false
    t.string   "codename",            limit: 255
    t.integer  "left_id",             limit: 4
    t.integer  "right_id",            limit: 4
    t.integer  "current_revision_id", limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "creator_id",          limit: 4,        null: false
    t.integer  "updater_id",          limit: 4,        null: false
    t.string   "read_rule_class",     limit: 255
    t.integer  "read_rule_id",        limit: 4
    t.integer  "references_expired",  limit: 4
    t.boolean  "trash",                                null: false
    t.integer  "type_id",             limit: 4,        null: false
    t.text     "db_content",          limit: 16777215
  end

  add_index "cards", ["key"], name: "cards_key_index", unique: true, using: :btree
  add_index "cards", ["left_id"], name: "cards_left_id_index", using: :btree
  add_index "cards", ["name"], name: "cards_name_index", using: :btree
  add_index "cards", ["read_rule_id"], name: "cards_read_rule_id_index", using: :btree
  add_index "cards", ["right_id"], name: "cards_right_id_index", using: :btree
  add_index "cards", ["type_id"], name: "cards_type_id_index", using: :btree

  create_table "schema_migrations_core_cards", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "schema_migrations_core_cards", ["version"], name: "unique_schema_migrations_cards", unique: true, using: :btree

  create_table "schema_migrations_deck_cards", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "schema_migrations_deck_cards", ["version"], name: "unique_schema_migrations_deck_cards", unique: true, using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255
    t.text     "data",       limit: 65535
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "sessions_session_id_index", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",               limit: 40
    t.string   "email",               limit: 100
    t.string   "crypted_password",    limit: 40
    t.string   "salt",                limit: 42
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_reset_code", limit: 40
    t.string   "status",              limit: 255, default: "request"
    t.integer  "invite_sender_id",    limit: 4
    t.string   "identity_url",        limit: 255
    t.integer  "card_id",             limit: 4,                       null: false
    t.integer  "account_id",          limit: 4,                       null: false
  end

end
