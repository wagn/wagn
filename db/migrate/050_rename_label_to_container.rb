class RenameLabelToContainer < ActiveRecord::Migration
  def self.up
    add_column :cards, :container, :boolean, :default=>false
    MTag.find_all_by_label(true).each do |tag|
      tag.root_card.container = true
      tag.root_card.save
    end
    
    # TODO:
    # remove_column :tags, :label
    
  end

  def self.down
    remove_column :cards, :container
  end
  
end
