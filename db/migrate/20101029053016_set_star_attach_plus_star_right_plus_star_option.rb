class SetStarAttachPlusStarRightPlusStarOption < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*attach+*right+*options", :type=>"Search"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
{"type": "File"}
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
