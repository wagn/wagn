class SetSettingPlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "Setting+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p><span>
<div>
<p>Settings control various options about how a card looks and behaves. Each card's Options tab has a "settings" subtab that lets you configure the settings that apply to that card.</p>
<p>&nbsp;</p>
<p><em>[[http://www.wagn.org/wagn/Setting|Learn more about settings.]]</em></p>
</div>
</span></p>
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
