class SetStarThankPlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*thanks+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Where to take people after they create a card in the [[set]]. [[http://www.wagn.org/wagn/Custom_thank_you_messages_for_forms|Learn more about thank you messages.]]</p>
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
