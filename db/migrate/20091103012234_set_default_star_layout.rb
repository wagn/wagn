class SetDefaultStarLayout < ActiveRecord::Migration
  def self.up
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*layout", :type=>"Pointer"
      if card.type != "Pointer"
        card.type = "Pointer"
      end
      card.content = ""
      card.save!
    end
  end

  def self.down
  end
end
