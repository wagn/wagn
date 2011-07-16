class SetStarTableOfContentPlusStarRightPlusStarEditHelp2 < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*table of contents+*right+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Autogenerate [[http://www.wagn.org/wagn/table_of_contents|table of contents]] when cards in the [[set]] have at least this many headers ("0" means never).</p>
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
