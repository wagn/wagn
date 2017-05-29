# -*- encoding : utf-8 -*-

class AddAdvancedEditCards < Card::Migration::Core
  def up
    ensure_card "*activity toolbar button", codename: "activity_toolbar_button"
    ensure_card "*rules toolbar button", codename: "rules_toolbar_button"
    ensure_card "Anyone With Role",
                codename: "anyone_with_role",
                type_id: Card::RoleID
  end
end
