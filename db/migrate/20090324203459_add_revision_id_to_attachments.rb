class AddRevisionIdToAttachments < ActiveRecord::Migration
  def self.up
    add_column :card_images, :revision_id, :integer
    add_column :card_files, :revision_id, :integer
  end

  def self.down
    remove_column :card_files, :revision_id
    remove_column :card_images, :revision_id
  end
end
