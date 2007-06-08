class RenameRoles < ActiveRecord::Migration
  def self.up   
    User.as_admin
    if card = Card::Role.find_by_name("Anonymous User")
      card.rename("Anyone")
    end
    if card = Card::Role.find_by_name("Authenticated User")
      card.rename("Anyone signed in")
    end
  end

  def self.down
  end
end
