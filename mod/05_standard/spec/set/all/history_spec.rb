# -*- encoding : utf-8 -*-

describe Card::Set::All::History do
  context "history view" do
    it 'should have a frame' do
      history = render_card :history, :name=>"A"
      assert_view_select history, 'div[class~="card-frame"]'
    end
  end
  
  context "store history" do
    it 'creates act for new card' do
      c = Card::Auth.as_bot do
        Card.create :name=>"historic card"
      end
      expect(c.acts.last.card_id).to eq(c.id)
      expect(c.acts.last.actions.last.changes.last).to eq(:create)
    end
    
    it 'creates act when card is deleted' do
      Card::Auth.as_bot do
        c = Card.fetch "historic card"
        c.delete
      end
      expect(c.acts.last.card_id).to eq(c.id)
      expect(c.acts.last.actions.last.changes.last).to eq(:delete)
    end
  end
end
