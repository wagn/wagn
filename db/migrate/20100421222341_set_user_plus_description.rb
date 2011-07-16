class SetUserPlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "User+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>People with accounts generally have a User card. To learn more, read the [[http://wagn.org/wagn/User|documentation about User cards]].</p>
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
