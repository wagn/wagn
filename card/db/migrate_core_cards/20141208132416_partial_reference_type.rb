# -*- encoding : utf-8 -*-

class PartialReferenceType < Card::Migration::Core
  def up
    Card::Reference.repair_all
  end
end
