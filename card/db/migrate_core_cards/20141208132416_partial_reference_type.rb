# -*- encoding : utf-8 -*-

class PartialReferenceType < Card::CoreMigration
  def up
    Card::Reference.repair_all
  end
end
