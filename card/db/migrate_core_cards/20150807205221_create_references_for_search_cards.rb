# -*- encoding : utf-8 -*-

class CreateReferencesForSearchCards < Card::CoreMigration
  def up
    Card.search(:type=>'Search').each do |card|
      card.update_references
    end
  end
end
