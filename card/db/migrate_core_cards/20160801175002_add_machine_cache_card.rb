# -*- encoding : utf-8 -*-

class AddMachineCacheCard < Card::Migration::Core
  def up
    create_or_update name: "*machine cache", codename: "machine_cache"
  end
end
