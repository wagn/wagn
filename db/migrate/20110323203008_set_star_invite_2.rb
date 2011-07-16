class SetStarInvite2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "*invite", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>People can <strong>invite new users via email</strong> if they have the [[/admin/tasks|global permission]] to "create accounts".</p>
<p>&nbsp;</p>
<p>Newy invited users will be sent an email with a password and the following details:</p>
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
<p><strong>After sending an invitation, you're taken here:</strong></p>
<blockquote>
<div>HTTP:// <em>(YOUR WAGN'S DOMAIN)</em> {{+*thanks}}</div>
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
