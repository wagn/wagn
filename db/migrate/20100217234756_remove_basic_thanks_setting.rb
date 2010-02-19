class RemoveBasicThanksSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    if c = Card["Basic+*type+*thanks"]
      c.destroy
    end
  end

  def self.down
  end
end
