class FixStarContentAndDefaultPerms < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      %w{ *content 
          *default 
          Cardtype+watcher_instructions_for_related_tab+*type_plus_right+*content
          watcher_instructions_for_related_tab+*right+*content
      }.each do |name|
      
        if card = Card[name]
          card.permit('read',  Role[:anon])
          card.save!
        end
      rescue
        puts "trouble saving #{card.name}"
      end
    end    
  end

  def self.down
  end
end
