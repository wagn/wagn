class UserCardId < ActiveRecord::Migration
  def up
    add_column :users, :card_id, :integer

    # populate the new column
    execute %{update users set card_id = c.id from cards c
               where c.extension_type = 'User' and c.extension_id = users.id }

    # change the created_by references from revisions table
    execute %{update revisions set created_by = c.id from cards c
               where c.extension_id = revisions.created_by and c.extension_type = 'User'}

    # change the created_by cards from revisions table
    execute %{update cards as cb set created_by = c.id from cards c
               where c.extension_id = cb.created_by and c.extension_type = 'User'}

    # change the updated_by cards from revisions table
    execute %{update cards as cb set updated_by = c.id from cards c
               where c.extension_id = cb.updated_by and c.extension_type = 'User'}

    change_column :users, :card_id, :integer, :null => false
  end

  def down
    remove_column :users, :card_id
  end
end
