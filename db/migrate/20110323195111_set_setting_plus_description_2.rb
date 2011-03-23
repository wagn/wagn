class SetSettingPlusDescription2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_new :name=>"Setting+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<div>Settings affect how cards look and behave. Each card's Options tab has a "settings" subtab.</div>
<div>&nbsp;</div>
<div><em>[[http://www.wagn.org/wagn/Setting|Learn more about settings.]]</em></div>
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
