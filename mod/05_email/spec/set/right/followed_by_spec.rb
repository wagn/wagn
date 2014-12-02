# -*- encoding : utf-8 -*-

describe Card::Set::Right::FollowedBy do
  
  describe 'view :raw' do
    def followers_raw_view card
      card.followed_by_card.format.render_raw
    end
    
    it 'renders an array of followers' do
      card = Card['All Eyes on me']
      raw_view = followers_raw_view card
      expect(raw_view).to eq ['Sara', 'John']
    end
    
    context 'new card created' do
      following = Card.fetch "Sara+*following"
      following << Card[:created_by_me]
      Card::Auth.current_id = Card['Sara'].id
      card = Card.create! :name=>"created by Sara"
      raw_view followers_raw_view card
      expect(raw_view).to include('created by Sara')
    end
  end
  
  describe 'view :core' do
    it 'renders a pointer list of followers' do
      raw_view = render_card :raw, 'All Eyes on me'
      expect(raw_view).to eq ["[[Sara]]\n[[John]]"]
    end
  end
    
end