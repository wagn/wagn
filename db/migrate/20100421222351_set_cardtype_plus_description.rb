class SetCardtypePlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "Cardtype+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p><span><span>Every card has a type, which shapes what kind of information goes into it. You can also add your own cardtypes. To learn more, read the [[http://wagn.org/wagn/card_types|documentation about card types]].<br></span></span></p>
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
