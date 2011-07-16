class SetStarAccountPlusStarRightPlusStarContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "*account+*right+*content", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<h1>[[_left+*roles|{{_left|name}}'s roles]]<br></h1>
<blockquote>
<div>{{_left+*roles|item:link}}</div>
</blockquote>
<div>&nbsp;</div>
<h1>[[_left+*watching|{{_left|name}} is watching]]</h1>
<blockquote>
<div>{{_left|name}} will receive email whenever these cards (or cards of types listed here) are changed. 
[[http://wagn.org/wagn/Notification|Learn more about notifications.]]</div>
<div>{{_left+*watching|item:change}}</div>
</blockquote>
<div>&nbsp;</div>
<h1>[[_left+*created|{{_left|name}} created]]</h1>
<blockquote>
<div>{{_left+*created}}</div>
</blockquote>
<div>&nbsp;</div>
<h1>[[_left+*editing|{{_left|name}} has edited]]</h1>
<blockquote>
<div>{{_left+*editing}}</div>
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
