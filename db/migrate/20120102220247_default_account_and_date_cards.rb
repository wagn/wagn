# encoding: utf-8
load 'db/helpers/wagn_migration_helper.rb'
class DefaultAccountAndDateCards < ActiveRecord::Migration 
  include WagnMigrationHelper

  def self.up
    [
      # The following two were previously handled with views but now have their own packs.
      
      [ "*when created+*right+*content", "Phrase", ''],
      [ "*when last edited+*right+*content", "Phrase", ''],

      # These three are just standard support content updates

      [ "email config+*right+*edit help", "Basic", <<CARDCONTENT
<p>Configures an email to be sent using [[http://wagn.org/flexible_email|flexible email]]. Note that [[http://www.wagn.org/wagn/contextual_names|contextual names]] here such as "_self" will refer to the card triggering the email.</p>
CARDCONTENT
      ],

      [ "*account", "Basic", <<CARDCONTENT
<div>
<p>[[/account/invite|Invite a new user]]</p>
<p></p>
<p>By default, new accounts are associated with [[User]] cards. [[http://wagn.org/wagn/account| Learn more about accounts.]]</p>
<p></p>
<h1>Account Requests</h1>
<p>{{Account Request+*type+by create}}</p>
<p></p>
<p>{{Cards with accounts|titled}}</p>
</div>
CARDCONTENT
      ],

      [ "*account+*right+*content", "Basic", <<CARDCONTENT
<h1>[[_left+*roles|{{_left|name}}'s roles]]<br></h1>
<blockquote>
<p>{{_left+*roles|item:link}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>[[_left+*watching|{{_left|name}} is watching]]</h1>
<blockquote>
<p>{{_left|name}} will receive email whenever these cards (or cards of types listed here) are changed. [[http://wagn.org/wagn/Notification|Learn more about notifications.]]</p>
<p>{{_left+*watching|item:change}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>[[_left+*created|{{_left|name}} created]]</h1>
<blockquote>
<p>{{_left+*created|item:change}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>[[_left+*editing|{{_left|name}} has edited]]</h1>
<blockquote>
<p>{{_left+*editing|item:change}}</p>
</blockquote>
CARDCONTENT
      ],

    ].each do |name, typecode, content|
      create_or_update_pristine Card.fetch_or_new(name), typecode, content.chomp
    end
  end

  def self.down
  end

end
