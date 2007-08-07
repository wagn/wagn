class SetUserDatatype < ActiveRecord::Migration
  def self.up   
    MUser.find(:all).each do |user|
      if user.card
        user.card.tag.update_attributes( :datatype_key => 'User' )
      else
#        raise "USER #{user.login} got not card"
        begin 
          #user.destroy
        rescue
          puts "User #{user} without card still tied to existing data"
        end

      end
    end
  end

  def self.down
    MUser.find(:all).each do |user|            
      user.card.tag.update_attributes( :datatype_key => 'Richtext' )
    end
  end
end
