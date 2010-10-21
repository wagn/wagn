class SetRolePlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Role+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Each [[user]] has one or more roles, and each role's capabilities are defined in [[/admin/tasks|Global permissions]] (except for the [[Administrator]] role, which has all permissions). [[http://wagn.org/wagn/Role|Learn more about roles]].</p>
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
