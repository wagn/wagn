# -*- encoding : utf-8 -*-
class CreateNewRevisionTables < ActiveRecord::Migration
  class TmpRevision < ActiveRecord::Base
    self.table_name = 'card_revisions'
  end
  class TmpAct < ActiveRecord::Base
    self.table_name = 'card_acts'
  end
  class TmpAction < ActiveRecord::Base
    self.table_name = 'card_actions'
  end
  class TmpChange < ActiveRecord::Base
    self.table_name = 'card_changes'
  end
  class TmpCard < ActiveRecord::Base
    belongs_to :tmp_revision, :foreign_key=>:current_revision_id
    has_many :tmp_actions, :foreign_key=>:card_id
    self.table_name = 'cards'
  end
  
  def up
    # remove_column :cards, :db_content
    # drop_table :card_acts
    # drop_table :card_actions
    # drop_table :card_changes
    #
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
    
    puts "Move revisions to action table..."
    count = 0
    created = Set.new
    TmpRevision.find_each do |rev|
      act = TmpAct.create(:id=>rev.id, :card_id=>rev.card_id, :actor_id=>rev.creator_id, :acted_at=>rev.created_at)
      if created.include? rev.card_id
        action = TmpAction.create( {:id=>rev.id, :card_id=>rev.card_id, :card_act_id=>act.id, :action_type=>1}, :without_protection=>true)
        TmpChange.create(:card_action_id=>action.id, :field=>2, :value=>rev.content )
      else
        action = TmpAction.create( {:id=>rev.id, :card_id=>rev.card_id, :card_act_id=>act.id, :action_type=>0}, :without_protection=>true)
        TmpChange.create(:card_action_id=>action.id, :field=>0, :value=>rev.card.name)
        TmpChange.create(:card_action_id=>action.id, :field=>1, :value=>rev.card.type_id)
        TmpChange.create(:card_action_id=>action.id, :field=>2, :value=>rev.content )
        created.add rev.card_id
      end
      if count == 100
        puts "another 100"
        count = 0
      end 
      count += 1
    end 
    puts "Finished revisions. Updating card table ... "
    TmpCard.find_each do |card|
      card.update_column(:db_content,card.tmp_revision.content) if card.tmp_revision
    end
    puts "Finshed card table"
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
