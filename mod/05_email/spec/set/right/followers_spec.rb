# -*- encoding : utf-8 -*-

describe Card::Set::Right::Followers do
  subject { @card.followers_card.item_names }
  
  describe 'raw content' do
    it 'renders a pointer list of followers' do
      card = Card.fetch 'All Eyes on me'
      expect(card.followers_card.raw_content).to eq(["[[Sara]]\n[[John]]"])
    end
  end
  
  describe 'item_names' do    
    it 'is an array of followers' do
      @card = Card['All Eyes On Me']
      is_expected.to eq ['John','Sara','Big Brother']
    end
    
    it 'recognizes card name changes' do
      @card = Card['Look At Me']
      @card.update_referencers = true
      @card.update_attributes! :name=>'Look away'
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
        @card = Card.create! :name=>"created by Follower"
        is_expected.to include('Big Brother')
      end
    end
    
    context 'when following "content I edited"' do
      it 'contains editor' do
        following = Card.fetch "Sara+*following"
        following << Card[:edited_by_me]
        following.save!
        @card = Card.create! :name=>"edited by Sara"
        Card::Auth.current_id = Card['Sara'].id
        @card.update_attributes! :content=> 'some content'
        is_expected.to include('Sara')
      end
    end
    
  end
    
end