# -*- encoding : utf-8 -*-

class RenameStatsToAdmin < Card::CoreMigration
  def up
    return unless (stats = Card[:stats])
    stats.update_attributes! name: '*admin', codename: 'admin'
  end
end
