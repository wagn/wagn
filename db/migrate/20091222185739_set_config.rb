class SetConfig < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Config", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<h1>Basics</h1>
<blockquote>
<p><em>Site name (appears in browser's title bar):</em> {{*title|closed;type:Phrase}}</p>
<p><em>Name of home card (if different from *title):</em> {{*home|closed;type:Phrase}}</p>
<p>{{*logo|closed;type:Image}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>Sidebar</h1>
<blockquote>
<p><em>[[http://wagn.org/wagn/sidebar|How to customize the sidebar]]</em></p>
<p>{{*sidebar|closed}}<em></em></p>
</blockquote>
<p>&nbsp;</p>
<h1>Account basics</h1>
<blockquote>
<p><em>Settings for inviting people, requesting accounts, and getting accounts approved ([[http://wagn.org/wagn/account#Administering%20accounts|learn more about accounts]]). See below to set the address that account-related emails come from, or to create a form for people who sign up.<br></em></p>
<p>{{*invite|closed}}</p>
<p>{{*request|closed}}</p>
<p>{{*signup|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>Advanced</h1>
<p>&nbsp;</p>
<h2>Appearance</h2>
<blockquote>
<p><em>[[http://wagn.org/wagn/Skin|Learn more about "skinning" your Wagn]].</em></p>
<em></em>
<p>{{*css|closed;type:HTML}}</p>
<p>{{Default Layout|closed;type:HTML}}</p>
<p>{{*favicon|closed;type:Image}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Account information emails</h2>
<blockquote>
<p><em>"From" address for emails that deliver user account information. (I.e., when someone signs up, is invited/approved, or forgot their password.)<br></em></p>
<p>{{*account+*from|closed;type:Phrase}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Account sign-up form</h2>
<blockquote>
<p><em>[[http://wagn.org/wagn/custom_sign-up_information|How to create a custom sign-up form]]<br></em></p>
<p>{{Account Request+*tform|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Edit toolbar</h2>
<blockquote>
<p><em>[[http://wagn.org/wagn/TinyMCE|How to customize the edit toolbar]]</em></p>
<p>{{*tinyMCE|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Notification emails</h2>
<blockquote>
<p><em>"From" address for emails notifying people of changes to cards they are watching. [[http://wagn.org/wagn/Notification|Learn more about notification]]</em></p>
<p>{{*notify+*from|closed;type:phrase}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Spam prevention (using captcha)<br></h2>
<blockquote><em>Require unregistered users to prove they are human whenever they create, edit, comment, or delete</em><em>:</em>
<p>{{*captcha|closed}}</p>
<p>&nbsp;</p>
<p><em>Note: your Wagn must be properly configured to run captchas.&nbsp; [[http://wagn.org/wagn/captcha|Learn more]]</em></p>
</blockquote>
<p>&nbsp;</p>
<h2>Related tab</h2>
<blockquote>
<p><em>[[*related|Some subtabs are available on every card]]:</em></p>
<p>{{Related subtabs - universal}}</p>
<p>&nbsp;</p>
<p><em>[[*related+*plus cards|Some subtabs]] appear only on cards of a given type:</em></p>
<p>{{Related subtabs - cardtypes}}</p>
<p>&nbsp;</p>
<p><em>A special subtab appears on cards with accounts:</em></p>
<p>{{*account+*rform|closed}}</p>
<p>&nbsp;</p>
<p><em>[[http://wagn.org/wagn/Related_tab|Learn more about the Related tab]].</em></p>
</blockquote>
<p>&nbsp;</p>
<h2>Form thanks<br></h2>
<blockquote>
<p><em>Where people will be taken after creating a card they don't have permission to see (learn more about [[http://wagn.org/wagn/Custom_thank_you_messages_for_forms|custom thank you messages for forms]]):</em></p>
<p>HTTP:// <em>(YOUR WAGN'S DOMAIN) </em>{{Basic+*type+*thanks}}</p>
</blockquote>
<p>&nbsp;</p>
<h2>Google Analytics</h2>
<blockquote>
<p><em>[[http://wagn.org/wagn/Google_Analytics|How to set up Google Analytics]]</em></p>
<p>{{*google analytics key|type:Phrase}}</p>
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
