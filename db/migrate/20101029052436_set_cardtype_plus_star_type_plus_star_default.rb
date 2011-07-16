class SetCardtypePlusStarTypePlusStarDefault < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "Cardtype+*type+*default", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>{{+description}}</p>
<p>&nbsp;</p>
<p>[[/new/{{_self|linkname}}|add a {{_self|name}} card]]</p>
<p>&nbsp;</p>
<h2>{{_self|name}} Cards</h2>
<blockquote>
<p>{{+*type cards}}</p>
</blockquote>
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
