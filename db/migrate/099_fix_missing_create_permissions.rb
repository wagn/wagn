class FixMissingCreatePermissions < ActiveRecord::Migration
  def self.up
    User.as :admin do
      Card::Cardtype.find(:all).reject {|x| x.who_can(:create) }.each do |ct| 
        ct.permit(:create, Role[:auth]); ct.save! 
      end
    end
  end

  def self.down
  end
end
