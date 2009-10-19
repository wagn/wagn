class SetStarThankPlusStarEdit < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*thanks+*edit", :type=>"Basic"
      if card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content <<CONTENT
<p>Where to take people when they create a card of this type (if they don't have permission to see it). [[http://www.wagn.org/wagn/Custom_thank_you_messages_for_forms|Learn more about thank you messages.]]</p>
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
