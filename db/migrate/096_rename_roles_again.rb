class RenameRolesAgain < ActiveRecord::Migration
  def self.up
    User.as :admin

    if c=Card['Anonymous User']
      c.name = 'Anyone'
      c.confirm_rename
      c.save!
    end

    if c=Card['Authenticated User']
      c.name = 'Anyone Signed In'
      c.confirm_rename
      c.save!
    end
  end

  def self.down
  end
end
