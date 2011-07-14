class SetConfig3 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "Config", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<h1>Basics</h1>
<div>&nbsp;</div>
<div>Set your site name, home card, and logo image:</div>
<blockquote>
<div><em></em>{{*title|closed;type:Phrase}}</div>
<div>{{*home|closed;type:Phrase}}<em></em></div>
<div>{{*logo|closed;type:Image}}</div>
</blockquote>
<div>&nbsp;</div>
<div>&nbsp;</div>
<h1>Sets / Settings</h1>
<div>&nbsp;</div>
<div>You can apply&nbsp;<em>[[settings]]</em>&nbsp;(configurations) to&nbsp;<em>[[sets]]&nbsp;</em>(groups) of cards.</div>
<blockquote>
<div>{{settings|open}}</div>
</blockquote>
<div>The [[*all]] set is for site-wide defaults:</div>
<blockquote>
<div>{{*all|closed}}</div>
</blockquote>
<div>&nbsp;</div>
<div>&nbsp;</div>
<h1>Email / Account Configuration</h1>
<div>&nbsp;</div>
<div>Configure account-related emails here:</div>
<blockquote>
<div>{{*request|closed}}</div>
<div>{{*signup|closed}}</div>
{{*invite|closed}}</blockquote>
<div>By default, system emails come from [[/card/options/Wagn_Bot| Wagn Bot's email address]] (set via the Options tab).</div>
<blockquote>
<div>{{Wagn Bot|closed}}</div>
</blockquote>
<div>You can [[http://www.wagn.org/wagn/custom_sign-up_information|further configure signups]] by&nbsp;[[http://www.wagn.org/wagn/formatting|formatting]]&nbsp;[[Account Request]] and [[User]] cards.</div>
<div>&nbsp;</div>
<div><em>[[http://www.wagn.org/wagn/account#Administering%20accounts | Learn  more about configuring accounts.]]</em></div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<h1>Miscellaneous options<br></h1>
<div>&nbsp;</div>
<blockquote>{{*css|closed;type:HTML}} <em>[[http://wagn.org/wagn/Skin|How to "skin" your Wagn]]</em>
<div>&nbsp;</div>
<div>{{*sidebar|closed}}<em> [[http://wagn.org/wagn/sidebar|How to  customize your sidebar]]</em></div>
<div>&nbsp;</div>
<div>{{*tinyMCE|closed}} <em>[[http://wagn.org/wagn/TinyMCE|How to customize your edit toolbar]]</em></div>
<div>&nbsp;</div>
<div>{{*google analytics key|closed; type:Phrase}} <em>[[http://wagn.org/wagn/Google_Analytics|How to set up Google  Analytics]]</em></div>
<div>&nbsp;</div>
<div>{{*favicon|closed;type:Image}} <em>[[http://www.wagn.org/wagn/favicon|How to customize your favicon]]</em></div>
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
