class UserCardId < ActiveRecord::Migration
  def up
    add_column :users, :card_id, :integer

    execute %{update users set card_id = c.id from cards c
               where c.extension_type = 'User' and c.extension_id = users.id }

    change_column :users, :card_id, :integer, :null => false
  end

  def down
    remove_column :users, :card_id
  end
end
