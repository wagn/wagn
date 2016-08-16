# -*- encoding : utf-8 -*-

class ChangeBootstrapCardTypeToScss < Card::Migration::Core
  def up
    if (card = Card[:bootstrap_cards])
      card.update_attributes! type_id: Card::ScssID
    end
  end
end
