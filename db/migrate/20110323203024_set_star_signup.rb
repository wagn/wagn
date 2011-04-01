class SetStarSignup < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_new :name=>"*signup", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>People can <strong>sign up with no approval process</strong>&nbsp;if you allow "Anyone" to [[/card/options/Account_Request|create account requests]], and give "Anyone" the [[/admin/tasks |global permission]] to create accounts.</p>
<p>&nbsp;</p>
<p>Newly registered users will be sent an email with a password and the following details:</p>
<p>&nbsp;</p>
<h2>Email Subject</h2>
<blockquote>
<p>{{*signup+*subject|type:Phrase}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Email Message</h2>
<blockquote>
<p>{{*signup+*message|closed;type:PlainText}}</p>
</blockquote>
<p>&nbsp;</p>
<p>As the email is sent, the<strong> person signing up will be sent here</strong>:</p>
<blockquote>
<div>HTTP://<em>(YOUR WAGN'S DOMAIN)</em> {{+*thanks}}</div>
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
