class SetSettingPlusStarSelfPlusStarTableOfContent < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"Setting+*self+*table of contents", :type=>"Number"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
0
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
