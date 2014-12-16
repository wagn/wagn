# -*- encoding : utf-8 -*-

class AddIgnoreCard < Wagn::CoreMigration
  def up
        Card.create! :name => "*ignoring", :codename=>"ignoring"
  end
end
