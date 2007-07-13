class InvitationRequests < ActiveRecord::Migration
  def self.up
    remove_column :users, :activated_at
    remove_column :users, :activation_code
    add_column :users, :status, :string, :null=>'false', :default=>'request'
    ::MUser.update_all "status='active'"    
                                                         
    # PAIN IN THE ASS-- can't remove not-null constraint via change column.
    # and i'd rather do this than write sql that only works in some databases
    rename_column :users, :invited_by, :invited_by_not_null 
    add_column :users, :invited_by, :integer, :null=>true
    ::MUser.update_all "invited_by=invited_by_not_null"
    remove_column :users, :invited_by_not_null
    
  end

  def self.down
    add_column :users, :activated_at,        :datetime
    add_column :users, :activation_code,     :string,   :limit => 40
    remove_column :users, :status

  end
end
