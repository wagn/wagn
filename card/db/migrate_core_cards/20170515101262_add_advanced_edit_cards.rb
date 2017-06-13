# -*- encoding : utf-8 -*-

class AddAdvancedEditCards < Card::Migration::Core
  def up
    ensure_card "*activity toolbar button", codename: "activity_toolbar_button"
    ensure_card "*rules toolbar button", codename: "rules_toolbar_button"
    ensure_card "Anyone With Role",
                codename: "anyone_with_role",
                type_id: Card::RoleID

    Card::Cache.reset_all
    ensure_card [:roles, :right, :options],
                type_id: Card::SearchTypeID,
                content: %({"type":"role", "not":{"codename":["in","anyone","anyone_signed_in, anyone_with_role"]}})

    ensure_card "*csv structure",
                type_id: Card::SettingID,
                codename: "csv_structure"
  end
end
