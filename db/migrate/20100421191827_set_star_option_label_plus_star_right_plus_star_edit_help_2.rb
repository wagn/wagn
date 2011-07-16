class SetStarOptionLabelPlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*option label+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Labels for [[Pointer]] options.&nbsp; Value is a card name, which is plussed to each of a Pointer's option cards to form label cards for radio button and checkbox items. E.g., "description" will make Wagn look for "option 1+description", "option 2+description", etc. [[http://www.wagn.org/wagn/Pointer|Learn more.]]</p>
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
