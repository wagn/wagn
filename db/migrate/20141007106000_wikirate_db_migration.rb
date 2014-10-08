class WikirateDbMigration < ActiveRecord::Migration
  
  def up
    add_index :card_acts, :card_id, :name=>'card_id_index'
    add_index :card_acts, :actor_id, :name=>'actor_id_index'
    add_index :card_actions, :card_id, :name=>'card_id_index'
    add_index :card_actions, :card_act_id, :name=>'card_act_id_index'
    add_index :card_changes, :card_action_id, :name=>'card_action_id_index'
  end

  def down
  end
end
