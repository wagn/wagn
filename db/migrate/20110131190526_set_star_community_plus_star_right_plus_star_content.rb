class SetStarCommunityPlusStarRightPlusStarContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*community+*right+*content", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<h1>[[_left+*editors|Editors]]</h1>
<blockquote>
<p>{{_left+*editors|item:link}}</p>
</blockquote>
<h1>[[_left+discussion|Discussion]]<br></h1>
<blockquote>
<p>{{_left+discussion|open}}</p>
</blockquote>
<h1>[[_left+tags|"{{_left|name}}" is tagged with]]</h1>
<blockquote>
<p>{{_left+tags}}</p>
</blockquote>
<p>&nbsp;</p>
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
