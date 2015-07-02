# -*- encoding : utf-8 -*-

class FixScriptBootstrapCardType < Card::CoreMigration
  def up
    Card[:script_bootstrap].update_attributes! :type_id=>Card::JavaScriptID
  end
end
