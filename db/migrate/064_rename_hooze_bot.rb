class RenameHoozeBot < ActiveRecord::Migration
  def self.up
    User.as_admin do
      if card = Card::User.find_by_name("Hooze Bot")
        card.rename("Wagn Bot")
      end
    end
  end
  

  def self.down
  end
end
