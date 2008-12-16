class RegenerateKeys < ActiveRecord::Migration
  def self.up 
    User.as(:admin) 
    MCard.find(:all).each do |card| 
      if card.key != card.name.to_key
        card.key = card.name.to_key  
        old_date = card.updated_at
        puts "Setting key: #{card.name} -> #{card.key}"
        begin
          card.save!
          execute %{ update cards set updated_at = #{quote(old_date)} where id=#{card.id}}
          #card.update_attribute("updated_at", 
        rescue
          c2 = Card.find(card.id)
          if c2.key != card.key
            Card.create :name=>"#{card.name}+broken key", :content=>"failed to change key from #{c2.key} to #{card.key}"
          end
        end
      end
    end
    
  end

  def self.down
  end
end
