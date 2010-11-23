class FixAmpersandKeys < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.find(:all, :conditions=>"name like '%&%'").each do |card|
      card.update_attribute(:key, card.name.to_key)
    end
  end

  def self.down
  end
end
