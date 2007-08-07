class RemoveConnectionCardtype < ActiveRecord::Migration
  def self.up
    if card = MCard.find_by_name_and_type("Connection", "Cardtype")
      if MCard.find_all_by_type('Connection').length < 1
        card.update_attribute('current_revision_id', nil)
        card.destroy
      end
    end
  end
  

  def self.down
  end
end
