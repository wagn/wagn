class RedowncaseEmail < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|  
      begin
        user.downcase_email!
        user.save!                
      rescue Exception => e
        puts "Error on #{user.email}: #{e.message}"
      end
    end    
  end

  def self.down
  end
end
