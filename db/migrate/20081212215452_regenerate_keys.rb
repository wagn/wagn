class RegenerateKeys < ActiveRecord::Migration
  def self.up
    MCard.find(:all).each do |card|
      card.key = card.name.to_key
      puts "Setting key: #{card.name} -> #{card.key}"
      begin
        card.save!
      rescue
        c2 = Card.find(card.id)
        if c2.key != card.key
          Card.create :name=>"#{card.name}+broken key", :content=>"failed to change key from #{c2.key} to #{card.key}"
        end
      end
    end
    
  end

  def self.down
  end
end
