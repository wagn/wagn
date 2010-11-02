class SetStarWatcher < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*watchers", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>These cards show who is getting email about changes to these cards or card types. ([[http://www.wagn.org/wagn/Notification|Learn more about notification.]]):</p>
<p>&nbsp;</p>
<p>{{+*right+by name}}</p>
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
