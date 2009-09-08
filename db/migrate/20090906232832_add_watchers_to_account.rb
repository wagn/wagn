class AddWatchersToAccount < ActiveRecord::Migration
  def self.up 
    c = Card.find_or_create :name=>"*account+*rform"
    c.content =<<-'CONTENT'
      <h1>{{_left|name}}'s roles<br /></h1>
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
  end

  def self.down
  end
end
