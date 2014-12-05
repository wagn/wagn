# -*- encoding : utf-8 -*-

describe Card::Set::Right::Followers do
  subject { @card.followers_card.item_names }
  
  describe 'view :raw' do    
    it 'renders an array of followers' do
      @card = Card['All Eyes On Me']
      is_expected.to eq ['John', 'Sara', 'Big Brother']
    end
    
    it 'recognizes card name changes' do
      @card = Card['Look At Me']
      @card.update_referencers = true
      @card.update_attributes! :name=>'Look away'
      binding.pry
      is_expected.to eq ['Big Brother']
    end
      
    it 'recognizes +*following changes' do
    end
    # it 'when following a including card' do
    #   it 'contains follower' do
    #
    #   end
    # end
    

    
    context 'when following a card' do 
      it 'contains follower' do
        @card = Card['All Eye On Me']
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following a *self set' do
      it 'contains follower' do
        @card = Card['Look At Me']
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following a *type set' do
      it 'contains follower' do
        @card = Card.create! :name=>'telescope', :type=>'Optic'
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following a *right set' do
      it 'contains follower' do
        @card = Card.create! :name=>'telescope+lens'
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following a *type plus right set' do
      it 'contains follower' do
        @card = Card['Sunglasses+tint']
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following "content I created"' do
      it 'contains creator' do
        Card::Auth.current_id = Card['Big Brother'].id
        card = Card.create! :name=>"created by Follower"
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following "content I edited"' do
      it 'contains editor' do
        following = Card.fetch "Sara+*following"
        following << Card[:edited_by_me]
        card = Card.create! :name=>"edited by Sara"
        raw_view = followers_raw_view card
        Card::Auth.current_id = Card['Sara'].id
        card.update_attributes! :content=> 'some content'
        expect(raw_view).to include('edited by Sara')
      end
    end
    
  end
  
  describe 'view :core' do
    it 'renders a pointer list of followers' do
      raw_view = render_card :raw, 'All Eyes on me'
      expect(raw_view).to eq ["[[Sara]]\n[[John]]"]
    end
  end
    
end