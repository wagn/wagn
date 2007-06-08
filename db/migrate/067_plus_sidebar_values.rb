class PlusSidebarValues < ActiveRecord::Migration
  def self.up
    if Card::Base.respond_to?(:find_all_by_plus_sidebar)
      Card.find_all_by_plus_sidebar(nil).each do |card|
        card.plus_sidebar = false
        card.save
      end          
    end
    change_column :cards, :plus_sidebar, :boolean, :default=>false, :null=>false
  end

  def self.down
    change_column :cards, :plus_sidebar, :boolean, :default=>nil
  end
end
