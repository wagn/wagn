class AddSearchCardtype < ActiveRecord::Migration
  def self.up
    User.as :admin do
      if c= Card.find_by_name("Search")
        c.name = "Search CardCopy"
        c.confirm_rename=true
        c.save!
      end
      Card::Cardtype.create! :name=>"Search"
    end
      
  end

  def self.down
  end
end
