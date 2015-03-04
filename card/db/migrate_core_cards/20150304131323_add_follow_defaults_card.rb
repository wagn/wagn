# -*- encoding : utf-8 -*-

class AddFollowDefaultsCard < Card::CoreMigration
  def up
    Card.create! :name=>'*follow defaults', :codename=>'follow_defaults', :type_code=>:pointer
  end
end
