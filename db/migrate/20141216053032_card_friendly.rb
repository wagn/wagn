class CardFriendly < ActiveRecord::Migration
  def up
    rename_index :card_acts, 'card_id', 'card_acts_card_id'
    rename_index :card_actions, 'card_id', 'card_actions_card_id'  
  end

  def down
    rename_index :card_acts, 'card_acts_card_id', 'card_id'
    rename_index :card_actions, 'card_actions_card_id', 'card_id'  
  end
end
