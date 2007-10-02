class PermissionsCardIdTaskConstraint < ActiveRecord::Migration
  def self.up 
    Card::Cardtype.find(:all).each do |ct|
      ## this part is to get rid of duplicates
      ct.permit(:create, ct.who_can(:create))
      ct.save!  
    end
    add_unique_index :permissions, :task, :card_id
  end

  def self.down
  end
end
