class AddRolesTables < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :codename, :string
      t.column :tasks, :string
    end
 
    create_table(:roles_users, :id=>false) do |t|
      t.column :role_id, :integer, :null=>false
      t.column :user_id, :integer, :null=>false
    end
    
  end

  def self.down
    drop_table :roles
    drop_table :roles_users
  end
end                                                      
