class SetEmailConfigPlusStarRightPlusStarEditHelp < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "email config+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>If used as a [[*send]] setting value, Wagn will send an email with the following fields when a card in the [[set]] is created.&nbsp; If the emails include [[http://www.wagn.org/wagn/relative_names|relative names]], the newly created card will be treated as "self".</p>
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
