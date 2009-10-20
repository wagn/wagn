class SetStarOptionLabelPlusStarEdit < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*option label+*edit", :type=>"Basic"
      if card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Sets the plus card used to make labels for radio button and checkbox items associated with Pointers. [[http://www.wagn.org/wagn/Pointer|Learn more.]]</p>
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
