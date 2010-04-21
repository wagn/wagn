class SetConfig2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Config", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<h1>Basics <em></em></h1>
<blockquote>
<p><em>Site name:</em> {{*title|closed;type:Phrase}}</p>
<p><em>Home card:</em> {{*home|closed;type:Phrase}}</p>
<p><em>Logo Image: </em>{{*logo|closed;type:Image}}</p>
</blockquote>
<p>&nbsp;</p>
<p>&nbsp;</p>
<h1>Sets / Settings</h1>
<p>&nbsp;</p>
<p>Wagn allows you to apply <em>[[settings]]</em> (configuration options) to <em>[[sets]] </em>(groups) of cards.</p>
<blockquote>
<p>{{settings|open}}</p>
</blockquote>
<p>Each of the above [[settings]] can be applied to any [[set]] of cards.&nbsp; A [[set]] may be as specific as a single card or as general as all cards. Settings applied to this "*all" set will apply to any card that does not have the same setting applied to a more specific set:</p>
<blockquote>
<p>{{*all|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<h1>Email / Account Configuration</h1>
<p>&nbsp;</p>
<p>By default system emails come from the [[Wagn  Bot|"Wagn Bot's"]] email address.&nbsp; Change it via the Options tab:</p>
<blockquote>
<p>{{Wagn Bot|closed}}</p>
</blockquote>
<p>The following two [[sets]] are important for configuring account-related [[cardtypes]]:</p>
<blockquote>
<p>{{Account Request+*type|closed}}</p>
<p>{{User+*type|closed}}</p>
</blockquote>
<p>Configure account-related emails here:</p>
<blockquote>
<p><em>User Invitation</em></p>
<p><em></em>{{*invite|closed}}</p>
<p><em>User Signup</em></p>
<p>{{*signup|closed}}</p>
<p><em>Account Request<br></em></p>
<p>{{*request|closed}}</p>
</blockquote>
<p>Valuable account administration cards are linked to from the [[Administrator Links]] card:</p>
<blockquote>
<p>{{Administrator Links|closed}}</p>
</blockquote>
<p><em>[[http://www.wagn.org/wagn/account#Administering%20accounts | Learn  more about configuring accounts]]</em></p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<h1>Other Config<br></h1>
<p>&nbsp;</p>
<blockquote>{{*css|closed;type:HTML}} <em>[[http://wagn.org/wagn/Skin|How to "skin" your Wagn]].</em>
<p>&nbsp;</p>
<p>{{*sidebar|closed}}<em> [[http://wagn.org/wagn/sidebar|How to  customize the sidebar]]</em></p>
<p>&nbsp;</p>
<p>{{*tinyMCE|closed}} <em>[[http://wagn.org/wagn/TinyMCE|How to customize the edit toolbar]]</em></p>
<p>&nbsp;</p>
<p>{{*google analytics key|type:Phrase}} <em>[[http://wagn.org/wagn/Google_Analytics|How to set up Google  Analytics]]</em></p>
<p>&nbsp;</p>
<p>{{*favicon|closed;type:Image}}</p>
<p>&nbsp;</p>
</blockquote>
<p>&nbsp;</p>
<p>&nbsp;</p>
<blockquote>
<p><em></em></p>
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
