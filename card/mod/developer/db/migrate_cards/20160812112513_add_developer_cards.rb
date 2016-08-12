# -*- encoding : utf-8 -*-

class AddDeveloperCards < Card::Migration
  def up
    ensure_card name: "*debug",
                codename: "debug"
    ensure_card name: "*debug+*right+*read",
                type_id: Card::PointerID,
                content: "[[Administrator]]"
  end
end
