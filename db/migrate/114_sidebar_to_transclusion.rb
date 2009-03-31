class SidebarToTransclusion < ActiveRecord::Migration
  def self.up
    User.as(:wagbot)  do
      if s = Card['*sidebar']   
        s.content = Card.search( :plus=>"*sidebar" ).map{|c| "{{#{c.name}|open}}" }.join("\n")
        s.save!
      end
    end
  end

  def self.down
  end
end
