require_dependency 'db/card_creator.rb'


class CountCardsTaggedCache < ActiveRecord::Migration
  def self.up
    add_column :tags, :card_count, :integer, :default=>0
    execute "drop view cards_tagged"
    MTag.find(:all).each do |tag|
      tag.card_count = (tag.cards.count || 0)
      tag.save
    end
    execute %{ alter table tags alter column card_count set not null }
  end

  def self.down
    remove_column :tags, :card_count
    #execute "drop view cards_tagged"
    execute %{
      create view cards_tagged AS 
      select c1.id, count(*) as count
      FROM cards c1 join cards c2 ON c2.tag_id=c1.tag_id
      WHERE c1.parent_id IS NULL AND c2.id<>c1.id  
      group by c1.id
    }
  end
end
