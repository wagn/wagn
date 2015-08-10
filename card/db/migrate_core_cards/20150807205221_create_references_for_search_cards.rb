# -*- encoding : utf-8 -*-

class CreateReferencesForSearchCards < Card::CoreMigration
  def up
    raise "not ready to run yet"
    Card.search(:type=>'Search').each do |card|
      card.update_references
    end
  end
end
