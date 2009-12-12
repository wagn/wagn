class MoreSettingsCleanup < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    Card.search(:right=>'*on right').each do |card|
      newname = "#{card.name.trunk_name}+*right"
      if existing=Card[newname]
        card.destroy!
      else
        card.name = newname
        card.confirm_rename=true
        card.update_referencers=false
        card.save!
      end
    end
    Card['*on right'].destroy!
    
    c = Card['*all']
    c.type='Set'
    c.save!
  end

  def self.down
  end
end
