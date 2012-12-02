class AccountId < ActiveRecord::Migration
  def up
    add_column :users, :account_id, :integer, :null=>false # add new column to refer to User+*account cards
  end

  def down
    remove_column :users, :account_id
  end
end
