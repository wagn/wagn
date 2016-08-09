# -*- encoding : utf-8 -*-

class AddTokenExpiration < Card::Migration
  def up
    create_card! name: "*expiration", codename: "expiration"
  end
end
