class SetStarInvite < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*invite", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p><em>Any signed-in user with the [[/admin/tasks|global permission]] to "create accounts" can invite new users via email.</em></p>
<p>&nbsp;</p>
<h2>Email subject</h2>
<blockquote>
<p>{{+*subject|type:Phrase}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Email message</h2>
<blockquote>
<p>{{+*message|type:PlainText}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Email from</h2>
<blockquote>
<p>{{+*from|type:Phrase}}</p>
</blockquote>
<p>&nbsp;</p>
<p><strong>After sending an invitation, you're taken here:</strong><span><strong></strong></span></p>
<blockquote>
<p>HTTP:// <em>(YOUR WAGN'S DOMAIN) </em>{{+*thanks}}</p>
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
