class SelfToTrait < ActiveRecord::Migration
  def up
    Card.where(Card.arel_table[:name].matches("%+*self+%")).each do |card|
      card.name = card.name.sub(/\+\*self\+/,'+')
      card.update_referencers = true
      card.save
    end
    Card.where(Card.arel_table[:name].matches("%+*self%")).each do |card|
      card.delete
    end
    Card.all.each do |card|
      prc = card.permission_rule_card :read
      if card.read_rule_id != prc.first.id or
          card.read_rule_class != prc.last
        card.read_rule_id = prc.first.id
        card.read_rule_class = prc.last
        card.save
      end
    end
  end

  def down
  end
end
