class PermissionsCardIdTaskConstraint < ActiveRecord::Migration
  def self.up 
    User.as :admin do
      Card::Cardtype.find(:all).each do |ct|
        ## this part is to get rid of duplicates  
        ct.permit(:create, ct.who_can(:create))        
        ct.save!  
        
        # IF THIS THROWS ERRORS, TRY THIS WORKAROUND:
=begin
        perm = ct.who_can(:create)
        Permission.find_all_by_task_and_card_id('create', ct.id).plot(:destroy)
        ct.permit(:create,perm)
        ct.save!

=end        
        
      end
    end
    add_unique_index :permissions, :task, :card_id
  end

  def self.down
  end
end
