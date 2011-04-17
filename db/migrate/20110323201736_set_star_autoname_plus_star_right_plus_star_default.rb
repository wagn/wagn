class SetStarAutonamePlusStarRightPlusStarDefault < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_new :name=>"*autoname+*right+*default", :type=>"Phrase"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content = ''
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
