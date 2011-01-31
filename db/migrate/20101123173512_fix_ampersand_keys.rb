class FixAmpersandKeys < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    cards = Card.find(:all, :conditions=>"name like '%&%'")
    cards.each do |card|
   #   begin
   #     name = card.name
   #     card.update_attribute(:key, name.to_key)
   #   rescue
   #     puts "ampersand key migration failed on #{name}"
   #   end
    end
  end

  def self.down
  end
end
