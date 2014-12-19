# -*- encoding : utf-8 -*-

class AddIgnoringCard < Wagn::CoreMigration
  def up
    Card.create! :name => "*ignoring", :codename=>"ignoring"
  end
end
