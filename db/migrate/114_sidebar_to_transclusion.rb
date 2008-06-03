class SidebarToTransclusion < ActiveRecord::Migration
  def self.up
    User.as(:admin) do
      if s = Card['*sidebar']
        s.type="Search"
        s.content = %q[ {"plus": "*sidebar", "view":"open"} ]
        s.save!
      end
    end
  end

  def self.down
  end
end
