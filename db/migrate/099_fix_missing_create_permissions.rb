class FixMissingCreatePermissions < ActiveRecord::Migration
  def self.up   
    Card::Cardtype.find(:all).reject {|x| x.who_can(:create) }.each do |ct| 
      ct.permit(:create, Role[:auth]); ct.save! 
    end
  end

  def self.down
  end
end
