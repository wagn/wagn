# -*- encoding : utf-8 -*-

class AddMoreFollowingCards < Wagn::CoreMigration
  def up
    Card.create! :name => "*follow", :codename=>"follow", :type_code=>:setting
    Card.create! :name => "always", :codename=>"always"
    Card.create! :name => "never", :codename=>"never"
    
    Card.create! :name => "*all+*follow", :type_code=>:pointer, :content=>'[[never]]'
  end
end
