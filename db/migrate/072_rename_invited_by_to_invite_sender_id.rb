class RenameInvitedByToInviteSenderId < ActiveRecord::Migration
  def self.up
    rename_column :users, :invited_by, :invite_sender_id
  end

  def self.down
    rename_column :users, :invite_sender_id, :invited_by
  end
end
