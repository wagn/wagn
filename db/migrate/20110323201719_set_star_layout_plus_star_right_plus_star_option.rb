class SetStarLayoutPlusStarRightPlusStarOption < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "*layout+*right+*options", :type=>"Search"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
{"type": "HTML"}
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
