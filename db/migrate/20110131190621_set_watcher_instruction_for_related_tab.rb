class SetWatcherInstructionForRelatedTab < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "watcher instructions for related tab", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>For the [[*community+*right+*content|community subtab]] of the Related tab:</p>
<p>&nbsp;</p>
<p>{{+*right+*content|open}}</p>
<p>&nbsp;</p>
<p>{{Cardtype+_+*type plus right+*content|open}}</p>
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
