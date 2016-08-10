# -*- encoding : utf-8 -*-

class ReorganizeScripts < Card::CoreMigration
  def up
    ensure_card name: "script: mods", type_id: Card::PointerID,
                codename: "script_mods"
    ensure_card name: "script: editors", type_id: Card::PointerID,
                codename: "script_editors"

    update_script_rules
  end

  def update_script_rules
    Card.search(type_id: Card::PointerID,
                right: { codename: "script" },
                link_to: "script: slot").each do |script_rule|
      [:script_tinymce, :script_ace, :bootstrap_js].each do |codename|
        name = Card[codename].name
        script_rule.drop_item name
      end
      script_rule.add_item "script: editors"
      script_rule.add_item "script: mods"
      script_rule.save!
    end
  end
end
