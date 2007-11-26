class AddPointerCardtype < ActiveRecord::Migration
  def self.up
    User.as :admin
    Card.create :name=>'Pointer', :type=>'Cardtype'
  end

  def self.down
    User.as :admin
    Card['Pointer'].destroy!
  end
end
