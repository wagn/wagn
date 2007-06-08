class RenameHoozeBot < ActiveRecord::Migration
  def self.up
    User.as_admin
    if card = Card::User.find_by_name("Hooze Bot")
      card.rename("Wagn Bot")
    end
  end

  def self.down
  end
end
