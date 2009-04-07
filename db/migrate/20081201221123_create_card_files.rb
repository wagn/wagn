class CreateCardFiles < ActiveRecord::Migration
  def self.up
    create_table :card_files do |t|
      t.string :filename
      t.string :content_type
      t.integer :size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :card_files
  end
end
