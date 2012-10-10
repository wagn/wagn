class UserCardId < ActiveRecord::Migration
  def up
    dbtype = ActiveRecord::Base.configurations[Rails.env]['adapter']

    add_column :users, :card_id, :integer
    rename_column :cards, :created_by, :creator_id
    rename_column :cards, :updated_by, :updater_id
    rename_column :card_revisions, :created_by, :creator_id

    # re-add the old names and make a copy of the columns
    add_column :cards, :created_by, :integer
    add_column :cards, :updated_by, :integer
    add_column :card_revisions, :created_by, :integer

    execute %{update card_revisions set created_by = creator_id}
    execute %{update cards set created_by=creator_id, updated_by = updater_id}

    if dbtype.to_s =~ /mysql/
      # populate the new column with card_id of the user extension
      execute %{update users u, cards c set u.card_id = c.id
                 where c.extension_type = 'User' and c.extension_id = u.id }

      # Update the fields to use card_ids instead of extension_ids
      # change the creator_id references from card_revisions table
      execute %{update card_revisions r, cards c set r.creator_id = c.id 
                 where c.extension_id = r.creator_id
                   and c.extension_type = 'User'}
      # change the creator_id, and updater_id references cards table
      execute %{update cards c, users u set c.creator_id = u.card_id
                 where u.id = c.creator_id }

      # change the updater_id cards from card_revisions table
      execute %{update cards c, users u set c.updater_id = u.card_id
                 where u.id = c.updater_id }

    else
      # populate the new column with card_id of the user extension
      execute %{update users as u set card_id = c.id from cards c
                 where c.extension_type = 'User' and c.extension_id = u.id }

      # Update the fields to use card_ids instead of extension_ids
      # change the creator_id references from card_revisions table
      execute %{update card_revisions as r set creator_id = c.id  from cards c
                 where c.extension_id = r.creator_id
                   and c.extension_type = 'User'}
      # change the creator_id, and updater_id references cards table
      execute %{update cards as c set creator_id = u.card_id from users u
                 where u.id = c.creator_id }

      # change the updater_id cards from card_revisions table
      execute %{update cards as c set updater_id = u.card_id from users u
                 where u.id = c.updater_id }

    end

    change_column :users, :card_id, :integer, :null => false
  end

  def down
    remove_column :users, :card_id
    execute %{update card_revisions set creator_id = created_by }
    execute %{update cards set creator_id=created_by, updater_id = updated_by}
    remove_column :card_revisions, :created_by
    remove_column :cards, :created_by
    remove_column :cards, :updated_by

    rename_column :cards, :creator_id, :created_by
    rename_column :cards, :updater_id, :updated_by
    rename_column :card_revisions, :creator_id, :created_by
  end
end
