class DeviseUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :crypted_password, :encrypted_password
      t.rename :salt, :password_salt
      t.rename :password_reset_code, :reset_password_token
      t.column :confirmation_token,   :string,  :limit => 20
      t.column :confirmed_at,         :datetime
      t.column :confirmation_sent_at, :datetime
      t.column :remember_token,       :string, :limit => 20
      t.column :remember_created_at,  :datetime
      t.column :sign_in_count,        :integer
      t.column :current_sign_in_at,   :datetime
      t.column :last_sign_in_at,      :datetime
      t.column :current_sign_in_ip,   :string
      t.column :last_sign_in_ip,      :string
   end
  end

  def self.down
  end
end
