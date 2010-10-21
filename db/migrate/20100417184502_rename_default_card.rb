class RenameDefaultCard < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    unless Card['*all+*default']
      if c = Card['Basic+*type+*default']
        c.update_attributes :name=>'*all+*default', :confirm_rename => true, :update_referencers => true
      else
        Card.create! :name=>'*all+*default'
      end
    end
  end

  def self.down
  end
end
