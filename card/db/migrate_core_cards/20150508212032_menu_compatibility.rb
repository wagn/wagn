# -*- encoding : utf-8 -*-

class MenuCompatibility < Card::CoreMigration
  def up
    # Add bootswatch shared to old skins so that menu works
    bootswatch_shared = Card[:bootswatch_shared]
    Card.search(type_id: Card::SkinID) do |skin|
      if skin.item_cards.find { |item_card| item_card.codename.to_s == "style_bootstrap_compatible" }
        skin.add_item! bootswatch_shared.name
      end
    end

    # Delete output files so all the styling and js changes take effect.
    # (this can be removed if/when later migrations update those things directly)
    [:style, :script].each do |setting|
      Card.search(
        right_id: Card::MachineOutputID,
        left: { right: { codename: setting.to_s } }
      ).each(&:delete!)
    end
  end
end
