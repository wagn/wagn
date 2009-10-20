class SetStarWatchingPlusStarRform < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_create :name=>"*watching+*rform", :type=>"Search"
      if card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
/* fixit - once "type" accepts card defs:
{"or": 
 {"and": {"plus": ["*watcher", {"refer_to": "_self"} ], "not": {"type": "Cardtype"} } },
 {"type": {"plus": ["*watcher", {"refer_to": "_self"} ], "type": "Cardtype"} }
}
*/

{"plus": ["*watcher", {"refer_to": "_self"} ] }
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
