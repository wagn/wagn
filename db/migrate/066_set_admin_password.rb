class SetAdminPassword < ActiveRecord::Migration
  def self.up  
    if user = User.find_by_login('admin') 
      user.update_attribute('crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c')
    end
  end

  def self.down
  end
end
