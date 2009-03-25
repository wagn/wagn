class FileDataTables < ActiveRecord::Migration
  def self.up
    create_table :db_files, :force => true do |t|
      t.binary :data
    end
    add_column :card_images, :db_file_id, :integer
  end

  def self.down
    remove_column :card_images, :db_file_id
    drop_table :db_files
  end
end
