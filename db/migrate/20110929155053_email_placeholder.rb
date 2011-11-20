class EmailPlaceholder < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      Card.create :name=>'*email+*right+*content', :content=>''
      Card.create :name=>'*email+*right+*read', :content=>'[[Administrator]]'
    end
  end

  def self.down
  end
end
