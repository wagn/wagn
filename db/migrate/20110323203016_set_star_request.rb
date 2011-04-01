class SetStarRequest < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_new :name=>"*request", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>People can <strong>request an account</strong> via a "Sign Up" link if you allow "Anyone" to [[/card/options/Account_Request|create account requests]].</p>
<p>&nbsp;</p>
<p>Unless [[*signup|approved automatically]], the <strong>request will be emailed to</strong>:</p>
<blockquote>
<p>{{+*to|closed;type:Phrase}}</p>
</blockquote>
<p>and the<strong> requester will be redirected here:</strong></p>
<blockquote>
<div>HTTP:// <em>(YOUR WAGN'S DOMAIN)</em> {{+*thanks}}</div>
</blockquote>
<div>You can <strong>approve/deny account requests [[Account Request|here]]</strong>.</div>
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
