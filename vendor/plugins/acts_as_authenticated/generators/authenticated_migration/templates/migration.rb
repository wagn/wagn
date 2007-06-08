class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= user_table_name %>", :force => true do |t|
      t.column :login,            :string, :limit => 40
      t.column :email,            :string, :limit => 100
      t.column :crypted_password, :string, :limit => 40
      t.column :salt,             :string, :limit => 40
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
  end

  def self.down
    drop_table "<%= user_table_name %>"
  end
end
