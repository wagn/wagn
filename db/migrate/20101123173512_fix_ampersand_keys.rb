class FixAmpersandKeys < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.find(:all, :conditions=>"name like '%&%'").each do |card|
      begin
        card.update_attribute(:key, card.name.to_key)
      rescue
        puts "ampersand key migration failed on #{card.name}"
      end
    end
  end

  def self.down
  end
end
