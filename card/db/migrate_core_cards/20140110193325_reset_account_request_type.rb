# -*- encoding : utf-8 -*-

class ResetAccountRequestType < Card::Migration::Core
  def up
    arcard = Card[:signup]
    if arcard.type_code != :cardtype
      arcard.update_attributes type_id: Card::CardtypeID
    end
  end
end
