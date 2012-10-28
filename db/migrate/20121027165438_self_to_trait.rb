class SelfToTrait < ActiveRecord::Migration
  def up
    Card.where(cards[:name].matches("%+*self+%")).each do |card|
      card.name = card.name.sub(/\+\*self\+/,'+')
      card.save
    end
  end

  def down
  end
end
