class RemoveBasicThanksSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card["Basic+*type+*thanks"].destroy
  end

  def self.down
  end
end
