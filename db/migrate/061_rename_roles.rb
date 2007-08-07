load 'db/card_creator.rb'

class RenameRoles < ActiveRecord::Migration
  def self.up   
    #MCard.reset_column_information
    ::User.as(:admin) do
      if card = MCard.find_by_name("Anonymous User")
        # this is bullshit-- the association works fine in console, but not in the migration
        tag = MTag.find( card.tag_id ) 
        tag.current_revision.update_attribute(:name, "Anyone")
      end
      if card = MCard.find_by_name("Authenticated User")
        tag = MTag.find( card.tag_id )
        tag.current_revision.update_attribute(:name, "Anyone signed in")
      end
    end
  end

  def self.down
  end
end
