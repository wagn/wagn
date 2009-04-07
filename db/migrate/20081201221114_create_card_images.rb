class CreateCardImages < ActiveRecord::Migration
  def self.up
    create_table :card_images do |t|
      t.string :card_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail 
      t.timestamps
    end
  end

  def self.down
    drop_table :card_images
  end
end
