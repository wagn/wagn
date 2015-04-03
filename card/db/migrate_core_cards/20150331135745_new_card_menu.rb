# -*- encoding : utf-8 -*-

class NewCardMenu < Card::CoreMigration
  def up
    Card.create! :name=>'follow dialog', :codename=>'follow_dialog'
    menu_js = Card[:script_card_menu]
    menu_js.update_attributes! :type_id=>Card::CoffeeScriptID
  end
end
