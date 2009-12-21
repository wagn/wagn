class AccountableSetting < ActiveRecord::Migration
  def self.up
    User.as :wagbot
    c = Card.find_or_create! :name => "*accountable", :type=>"Setting"
    if c and c.type!="Setting"
      c.type = "Setting"
      c.save!
    end
    c = Card.find_or_create! :name => "*accountable+*rform", :type=>"Toggle"
  end

  def self.down
  end
end
