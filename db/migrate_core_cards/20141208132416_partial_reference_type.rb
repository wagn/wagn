# -*- encoding : utf-8 -*-

class PartialReferenceType < Wagn::CoreMigration
  def up
    Card.all.each do |card|
      card.update_references
    end
  end
end
