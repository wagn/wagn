class SelfToTrait < ActiveRecord::Migration
  def up
    Card.where(cards[:name].matches("%+*self+%")).each do |card|
      card.name = card.name.sub(/\+\*self\+/,'+')
      prc = card.permission_rule_card :read
      card.save
    end
    Card.where(cards[:name].matches("%+*self%")).each do |card|
      card.delete
    end
    Card.find_all.each do |card|
      card.read_rule_id = prc.first.id
      card.read_rule_class = prc.last
      card.save
    end
  end

  def down
  end
end
