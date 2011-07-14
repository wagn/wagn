class SetStarAccountablePlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*accountable+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>When "yes", users with the global "create accounts" permission can add [[http://www.wagn.org/wagn/account|accounts]] to cards in the [[set]].</p>
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
