class RoleRformAndHoozeBot < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    if c = Card['Hooze Bot']
      c.name = 'Wagn Bot'
      c.confirm_rename = true
      c.save
    end
    
    unless Card['*role+*rform']
      Card.create!(
        :name=>'*role+*rform', 
        :type=>'Search', 
        :content=>'{"member": "_self"}')
    end
    
  end

  def self.down
  end
end
