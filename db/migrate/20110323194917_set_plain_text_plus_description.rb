class SetPlainTextPlusDescription < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.find_or_new :name=>"PlainText+description", :type=>"Basic"
      if card.revisions.empty? || card.revisions.map(&:author).map(&:login).uniq == ["wagbot"]
        card.content =<<CONTENT
<div>PlainText cards are for unstyled text.</div>
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
