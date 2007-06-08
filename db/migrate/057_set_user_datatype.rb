class SetUserDatatype < ActiveRecord::Migration
  def self.up   
    User.find(:all).each do |user|
      if user.card
        user.card.tag.update_attributes( :datatype_key => 'User' )
      else
        begin 
          user.destroy
        rescue
          warn "User #{user} without card still tied to existing data"
        end
      end
    end
  end

  def self.down
    Card::User.find(:all).each do |card|            
      card.tag.update_attributes( :datatype_key => 'Richtext' )
    end
  end
end
