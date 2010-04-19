class RenameAccountFromToInviteFrom < ActiveRecord::Migration
  def self.up
    User.as(:wagbot)
    if c = Card["*account+*from"]
      c.name = "*invite+*from"
      c.save!
    end
  end

  def self.down
  end
end
