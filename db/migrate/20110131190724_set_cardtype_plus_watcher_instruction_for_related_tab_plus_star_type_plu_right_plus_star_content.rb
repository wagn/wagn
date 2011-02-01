class SetCardtypePlusWatcherInstructionForRelatedTabPlusStarTypePluRightPlusStarContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Cardtype+watcher instructions for related tab+*type plus right+*content", :type=>"Phrase"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
People receiving email when [[_left]] cards are changed.
CONTENT
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
