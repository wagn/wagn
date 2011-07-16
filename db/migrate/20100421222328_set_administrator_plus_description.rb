class SetAdministratorPlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "Administrator+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Administrators automatically have all of the [[/admin/tasks|global permissions]], and has the power to see, edit and delete every card in the system regardless of its permissions settings. See the [[http://wagn.org/wagn/permissions|documentation about permissions]].</p>
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
