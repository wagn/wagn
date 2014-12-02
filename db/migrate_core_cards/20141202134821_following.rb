# -*- encoding : utf-8 -*-

class Following < Wagn::CoreMigration
  def up
    Card.create! :name => "*followed by", :codename=>"followed_by"
    Card.create! :name => "content I created", :codename=>"created_by_me"
    Card.create! :name => "content I edited", :codename=>"edited_by_me"
  end
end
