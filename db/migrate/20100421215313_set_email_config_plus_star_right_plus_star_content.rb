class SetEmailConfigPlusStarRightPlusStarContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"email config+*right+*content", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>{{+*from}}</p>
<p>{{+*to}}</p>
<p>{{+*cc}}</p>
<p>{{+*bcc}}</p>
<p>{{+*subject}}</p>
<p>{{+*message}}</p>
<p>{{+*attach}}</p>
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
