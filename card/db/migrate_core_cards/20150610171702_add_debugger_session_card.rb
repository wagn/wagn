# -*- encoding : utf-8 -*-

class AddDebuggerSessionCard < Card::CoreMigration
  def up
    Card.create! :name=>'*debugger', :type_code=>:session, :codename=>'debugger'
  end
end
