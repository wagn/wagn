# -*- encoding : utf-8 -*-
class CreateNewRevisionTables < ActiveRecord::Migration
  def up
    # remove_column :cards, :db_content
    # drop_table :card_acts
    # drop_table :card_actions
    # drop_table :card_changes
    
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
    
    Card::Revision.order(:created_at).each do |rev|
      act = Card::Act.create(:card_id=>rev.card_id, :actor_id=>rev.creator_id, :acted_at=>rev.created_at)
      action = Card::Action.create(:card_id=>rev.card_id, :card_act_id=>act.id, :action_type=>:create)
      Card::Change.create(:card_action_id=>action.id, :field=>:db_content, :value=>rev.content )
    end 
    
    Card.all.each do |card|
      card.update_column(:db_content,card.current_revision.content)
    end
    #drop_table :card_revisions
    #remove_column :cards, :current_revision
  end

  def down
    remove_column :cards, :db_content
    drop_table :card_acts
    drop_table :card_actions
    drop_table :card_changes
  end
end
