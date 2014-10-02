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
  end

  def down
    remove_column :cards, :db_content
    drop_table :card_acts
    drop_table :card_actions
    drop_table :card_changes
  end
end
