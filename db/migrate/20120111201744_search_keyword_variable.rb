class SearchKeywordVariable < ActiveRecord::Migration
  def up
    User.as :wagbot do
      c = Card.fetch_or_new '*search'
      c.typecode = 'Search'
      c.content.sub '"_keyword"', '"$keyword"'
      c.save!
    end
  end

  def down
    User.as :wagbot do
      c = Card.fetch_or_new '*search'
      c.typecode = 'Search'
      c.content.sub '"$keyword"', '"_keyword"'
      c.save!
    end
  end
end
