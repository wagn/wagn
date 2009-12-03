class RedowncaseEmail < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      user.downcase_email!
      user.save!
    end
    
  end

  def self.down
  end
end
