class UserCardId < ActiveRecord::Migration
  def up
    add_column :users, :card_id, :integer
    change_column :cards, :created_by, :creator_id, :integer
    change_column :cards, :updated_by, :updater_id, :integer
    change_column :revisions, :created_by, :creator_id, :integer

    # re-add the old names and make a copy of the columns
    add_column :cards, :created_by, :integer
    add_column :cards, :updated_by, :integer
    add_column :revisions, :created_by, :integer
    execute %{update revisions set created_by = creator_id}
    execute %{update cards set created_by, updated_by = creator_id, updater_id}

    # populate the new column with card_id of the user extension
    execute %{update users set card_id = c.id from cards c
               where c.extension_type = 'User' and c.extension_id = users.id }

    # Update the fields to use card_ids instead of extension_ids
    # change the creator_id references from revisions table
    execute %{update revisions set creator_id = c.id from cards c
               where c.extension_id = revisions.creator_id
                 and c.extension_type = 'User'}
    # change the creator_id, and updater_id references cards table
    execute %{update cards as cb set creator_id = c.id from cards c
               where c.extension_id = cb.creator_id
                 and c.extension_type = 'User'}

    # change the updater_id cards from revisions table
    execute %{update cards as cb set updater_id = c.id from cards c
               where c.extension_id = cb.updater_id
                 and c.extension_type = 'User'}

    change_column :users, :card_id, :integer, :null => false
  end

  def down
    remove_column :users, :card_id
    execute %{update revisions set creator_id = created_by }
    execute %{update cards set creator_id, updater_id = created_by, updated_by}
    remove_column :revisions, :created_by
    remove_column :cards, :created_by
    remove_column :cards, :updated_by

    change_column :cards, :creator_id, :created_by, :integer
    change_column :cards, :updater_id, :updated_by, :integer
    change_column :revisions, :creator_id, :created_by, :integer
  end
end
