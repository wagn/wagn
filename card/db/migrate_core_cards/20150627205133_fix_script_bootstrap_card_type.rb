# -*- encoding : utf-8 -*-

class FixScriptBootstrapCardType < Card::CoreMigration
  def up
    Card[:bootstrap_js].update_attributes! type_id: Card::JavaScriptID
  end
end
