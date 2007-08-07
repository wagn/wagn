class RenameHoozeBot < ActiveRecord::Migration
  def self.up
    User.as(:admin) do
      if card = MCard.find_by_name("Hooze Bot")
        tag = MTag.find( card.tag_id ) 
        tag.current_revision.update_attribute(:name, "Wagn Bot")
      end
    end
  end
  

  def self.down
  end
end
