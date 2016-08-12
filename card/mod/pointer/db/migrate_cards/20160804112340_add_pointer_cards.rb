# -*- encoding : utf-8 -*-

class AddPointerCards < Card::Migration
  def up
    ensure_card name: "script: pointer config",
                type_id: Card::CoffeeScriptID,
                codename: "script_pointer_config"
  end
end
