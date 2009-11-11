class CleanupUserTable < ActiveRecord::Migration
  def self.up
    User.find(:all, :conditions=>["blocked=?",true]).each do |user|
      user.status = 'blocked'
      user.save!
    end
    
    remove_column :users, :blocked
    remove_column :users, :cards_per_page
    remove_column :users, :hide_duplicates
  end

  def self.down
    add_column :users, :hide_duplicates, :boolean,  :default => true,   :null => false
    add_column :users, :cards_per_page, :integer,   :default => 25,     :null => false
    add_column :users, :blocked, :boolean,          :default => false,  :null => false
  end
end
