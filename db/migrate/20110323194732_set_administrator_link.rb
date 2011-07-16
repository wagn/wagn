class SetAdministratorLink < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_new "Administrator links", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<div>[[Config|Configure your Wagn]]</div>
<div>&nbsp;</div>
<div>[[*account|Accounts]] | [[Roles]] | [[/admin/tasks|Global permissions]]</div>
<div>&nbsp;</div>
<div>[[/admin/clear_cache|Clear the cache]]</div>
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
