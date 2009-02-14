class AddCardReferenceToCardImages < ActiveRecord::Migration
  def self.up
    add_column :card_images, :card_id, :integer
  end

  def self.down
    remove_column :card_images, :card_id
  end
end
