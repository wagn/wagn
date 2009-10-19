class SetStarAccountPlusStarRform < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*account+*rform", :type=>"Basic"
      if card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content <<CONTENT
<h1>{{_left|name}}'s roles<br></h1>
<blockquote>
<p>{{_left+*roles|item:link}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>Cards {{_left|name}} is watching</h1>
<blockquote>
<p>You'll receive email whenever these cards (or cards of types listed here) are changed. [[http://wagn.org/wagn/Notification|Learn more about notifications]].</p>
<p>{{_left+*watching|item:change}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>Cards {{_left|name}} has edited</h1>
<blockquote>
<p>{{_left +*editing}}</p>
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
