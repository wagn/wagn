class AddPatternCardtype < ActiveRecord::Migration
  def self.up 
  	User.as :wagbot do
   	  Card.create! :name=>"Pattern", :type=>"Cardtype", :codename=>"Pattern"
  	end
  end

  def self.down
  end
end
