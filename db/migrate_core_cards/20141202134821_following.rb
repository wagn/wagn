# -*- encoding : utf-8 -*-

class Following < Wagn::CoreMigration
  def up
    Card.create! :name => "*followers", :codename=>"followers"
    Card.create! :name => "content I created", :codename=>"created_by_me"
    Card.create! :name => "content I edited", :codename=>"edited_by_me"
    Card.create! :name => "*follow fields", :codename=>"follow_fields", :type_code=>:setting
    Card.create! :name => "*follow fields+*right+*help", :content=>""
    Card.create! :name => "*follow fields+*right+*default", :type_code=>:pointer
    Card.create! :name => "*all+*follow fields", :content=>"[[*include]]", :type_code=>:pointer
  end
end
