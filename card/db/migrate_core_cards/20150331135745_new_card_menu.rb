# -*- encoding : utf-8 -*-

class NewCardMenu < Card::CoreMigration
  def up
    menu_js = Card[:script_card_menu]
    menu_js.update_attributes! type_id: Card::CoffeeScriptID
  end
end
