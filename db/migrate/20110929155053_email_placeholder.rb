class EmailPlaceholder < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      Card.create :name=>'*email+*right+*content'
    end
  end

  def self.down
  end
end
