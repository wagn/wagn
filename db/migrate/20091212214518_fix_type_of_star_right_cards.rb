class FixTypeOfStarRightCards < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    tmpl = Card['*right+*rform']
    tmpl.update_attribute :extension_type, 'SoftTemplate'

    Card.search(:right=>'*right').each do |card|
      card.type = 'Set'
      card.save!
    end
    
    tmpl.update_attribute :extension_type, 'HardTemplate'
  end

  def self.down
  end
end
