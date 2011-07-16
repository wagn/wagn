class SetEmailConfigPlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "email config+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<div>Configures an email to be sent using [[http://wagn.org/flexible_email|flexible email]]. Note that [[http://www.wagn.org/wagn/contextual_names|contextual names]] here such as "_self" will refer to the card triggering the email.</div>
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
