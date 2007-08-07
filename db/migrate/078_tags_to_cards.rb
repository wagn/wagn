load 'db/card_creator.rb'
                              
# redefine the MCard classes to use old_tag_id
class ::MCard < ActiveRecord::Base
  set_table_name 'cards'
  set_inheritance_column nil
  belongs_to :tag, :class_name=>'MTag', :foreign_key=>"old_tag_id"
  belongs_to :extension, :polymorphic=>true
end

class ::MTag < ActiveRecord::Base
  set_table_name 'tags'
  has_one :root_card, :class_name=>'MCard', :foreign_key=>"old_tag_id",:conditions => "trunk_id IS NULL"
  has_many :cards, :class_name=>'MCard', :foreign_key=>"old_tag_id", :conditions=>"trunk_id IS NOT NULL", :dependent=>:destroy
  belongs_to :current_revision, :class_name=>'MTagRevision', :foreign_key=>'current_revision_id'
end

class TagsToCards < ActiveRecord::Migration
  def self.up
    begin drop_foreign_key 'cards', 'tag_id'; rescue; end
    # yikes some dbs still have this..
    begin drop_constraint 'cards', 'pages_tag_id_fkey'; rescue; end
    

    # done in this hacky way to get around/rid of the 'not null' contraint on tag_id/old_tag_id
    add_column :cards, :old_tag_id, :integer, :null=>true
    execute "update cards set old_tag_id=tag_id"
    remove_column :cards, :tag_id
    add_column :cards, :tag_id, :integer

    # after we mess with the columns.. 
    MCard.reset_column_information
    
    MCard.find(:all).each do |card|   
      if card.trunk_id.nil?
        card.tag_id = nil
      else
        if card.tag.root_card
          card.tag_id = card.tag.root_card.id
        else
          warn "HELP! Couldn't find root card for tag #{card.tag.id}"
        end
      end
      card.save!
    end 
    add_foreign_key 'cards','tag_id','cards'
  end

  def self.down                               
    remove_column :cards, :tag_id
    rename_column :cards, :old_tag_id, :tag_id
  end
end
