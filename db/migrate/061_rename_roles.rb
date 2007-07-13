class RenameRoles < ActiveRecord::Migration
  def self.up   
    User.as_admin do
      if card = Card::Role.find_by_name("Anonymous User")
        card.rename("Anyone")
      end
      if card = Card::Role.find_by_name("Authenticated User")
        card.rename("Anyone signed in")
      end
    end
  end

  def self.down
  end
end
