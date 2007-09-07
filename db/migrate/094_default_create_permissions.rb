class DefaultCreatePermissions < ActiveRecord::Migration
  def self.up
    Cardtype.find(:all).each do |ct|    
      next if ct.codename=='Basic'  #already done
      ct.card.permissions << Permission.new({:task=>'create', :party=>Role[:auth]}) 
    end
  end

  def self.down
  end
end
