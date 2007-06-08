class CardsTaggedView < ActiveRecord::Migration
  def self.up
    execute %{
      create view cards_tagged AS 
      select c1.id, count(*) as count
      FROM cards c1 join cards c2 ON c2.tag_id=c1.tag_id
      WHERE c1.parent_id IS NULL AND c2.id<>c1.id  
      group by c1.id
    }
  end

  def self.down
    execute "drop view cards_tagged"
  end
end
