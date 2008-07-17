class ChangeTemplateNames < ActiveRecord::Migration
  def self.up
    if User.as :admin
      Card.reset_column_information 
    
      Card.search(:right=>'*template').each do |card|
        if card.trunk.type == 'Cardtype'
          card.name = card.trunk.name+'+*tform'
        else
          card.name = card.trunk.name+'+*rform'
        end
  		  card.confirm_rename = true
  		  card.update_link_ins = true
        card.save!
      end
    end
  end

  def self.down
  end
end
