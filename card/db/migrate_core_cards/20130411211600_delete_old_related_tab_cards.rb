# -*- encoding : utf-8 -*-

class DeleteOldRelatedTabCards < Card::CoreMigration
  def up
    [
      "*related",
      "*incoming",
      "*outgoing",
      "*community",
      "*plusses",
      "watcher instructions for related tab"
    ].each do |name|
      c = Card[name]
      c.codename = nil
      c.delete!
    end
  end
end
