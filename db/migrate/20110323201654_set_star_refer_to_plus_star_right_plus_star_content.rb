class SetStarReferToPlusStarRightPlusStarContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "*refers to+*right+*content", :type=>"Search"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
{"referred_to_by":"_self"}
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
