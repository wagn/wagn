# -*- encoding : utf-8 -*-

class RenameStatsToAdmin < Card::Migration::Core
  def up
    return if Card::Codename[:admin] || !Card::Codename[:stats]
    Card[:stats].update_attributes! name: "*admin", codename: "admin"
  end
end
