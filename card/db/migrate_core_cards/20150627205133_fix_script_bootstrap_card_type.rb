# -*- encoding : utf-8 -*-

class FixScriptBootstrapCardType < Card::Migration::Core
  def up
    Card[:bootstrap_js].update_attributes! type_id: Card::JavaScriptID
  end
end
