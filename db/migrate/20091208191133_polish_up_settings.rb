class PolishUpSettings < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    
    Card.search(:or=> {:right=>'*table of contents', :name=>'*table of contents+*rform'}).each do |card|
      card.type='Number'  #update attributes didn't take
      card.save!
    end
    
    Card.search(:right => '*captcha').each do |card|
      card.content = (card.content=~/1/ ? '1' : '0')
      card.type = 'Toggle'
      card.save!
    end
    
    Card.find_or_create(:name=>'*captcha+*rform', :type=>'Toggle', :content=>'1')
    
    (%w{ *type *self *right }<<'*type plus right').each do |setclassname|
      Card["#{setclassname}+*rform"].update_attribute :extension_type, ''      
    end
  end

  def self.down
  end
end
