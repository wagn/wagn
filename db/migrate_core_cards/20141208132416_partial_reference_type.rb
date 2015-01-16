# -*- encoding : utf-8 -*-

class PartialReferenceType < Wagn::CoreMigration
  def up
    Card::Reference.repair_all
  end
end
