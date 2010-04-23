class SetStarAddHelpPlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*add help+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p><span> </span></p>
<div>
<p><span> </span></p>
<div>
<p>[[http://www.wagn.org/wagn/custom_help_text|Help text]] people will see when adding cards in the [[set]].</p>
</div>
</div>
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
