# -*- encoding : utf-8 -*-

class AddMachineCacheCard < Card::CoreMigration
  def up
    create_or_update name: "*machine cache", codename: "machine_cache"
  end
end
