class FixLegacyTrunkAndTagIds < ActiveRecord::Migration
  def self.up
    User.as :admin
     cards = Card.find_by_sql("select * from cards where name not like '%+%' and (trunk_id is not null or tag_id is not null)")
     cards.each do |card|
       card.trunk_id = card.tag_id = nil
       card.save!
     end
     
  end

  def self.down
  end
end
