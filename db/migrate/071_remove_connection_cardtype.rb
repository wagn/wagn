class RemoveConnectionCardtype < ActiveRecord::Migration
  def self.up
    ::User.as_admin do 
      if card = Card::Cardtype.find_by_name("Connection")
        if Card::Connection.find(:all).length < 1
          card.destroy
        end
      end
    end
  end
  

  def self.down
  end
end
