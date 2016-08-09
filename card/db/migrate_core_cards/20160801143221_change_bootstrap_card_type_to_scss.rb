# -*- encoding : utf-8 -*-

class ChangeBootstrapCardTypeToScss < Card::CoreMigration
  def up
    if (card = Card[:bootstrap_cards])
      card.update_attributes! type_id: Card::ScssID
    end
  end
end
