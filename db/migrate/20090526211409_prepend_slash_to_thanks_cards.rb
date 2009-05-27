class PrependSlashToThanksCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.search(:right=>'*thanks').each do |card|
      card.content = "/" + card.content
      card.save!
    end
  end

  def self.down
  end
end
