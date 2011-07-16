class SetStarSidebarPlusStarSelfPlusStarEditHelp < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "*sidebar+*self+*edit help", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<p>Contents will appear on sidebar. [[http://www.wagn.org/wagn/sidebar|Learn more about the sidebar.]]</p>
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
