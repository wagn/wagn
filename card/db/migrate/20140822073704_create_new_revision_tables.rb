# -*- encoding : utf-8 -*-
class CreateNewRevisionTables < ActiveRecord::Migration
  def up
    add_column :cards, :db_content, :text

    create_table :card_acts do |t|
      t.integer  :card_id
      t.integer  :actor_id
      t.datetime :acted_at
      t.string   :ip_address
    end

    create_table :card_actions do |t|
      t.integer :card_id
      t.integer :card_act_id
      t.integer :super_action_id
      t.integer :action_type
      t.boolean :draft
    end

    create_table :card_changes do |t|
      t.integer :card_action_id
      t.integer :field
      t.text    :value
    end

    add_index :card_acts, :card_id, name: "card_id_index"
    add_index :card_acts, :actor_id, name: "actor_id_index"
    add_index :card_actions, :card_id, name: "card_id_index"
    add_index :card_actions, :card_act_id, name: "card_act_id_index"
    add_index :card_changes, :card_action_id, name: "card_action_id_index"
    # add_index :card_actions, [:card_id, :draft], name: 'card_id_and_draft_index'
    # add_index :card_changes, [:card_action_id, :field], name: 'card_action_id_and_field_index'
  end

  def down
    remove_column :cards, :db_content
    drop_table :card_acts
    drop_table :card_actions
    drop_table :card_changes
  end
end
