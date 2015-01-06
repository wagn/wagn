# -*- encoding : utf-8 -*-

describe Card::Set::Right::Following do
  describe 'event: normalized following entry' do
    subject do 
      Card::Auth.as_bot { Card.create(:name=>"Joe User+*following", :content=>"[[#{follow}]]").content } 
    end
    
    context 'for a set card' do
      let(:follow) { "No One Sees Me+*self"}
      it { is_expected.to eq '[[No One Sees Me+*self+always]]'}
    end   
    context 'for a type card' do
      let(:follow) { 'Basic' }
      it { is_expected.to eq '[[Basic+*type+always]]'}
    end    
    context 'for a follow option card' do
      let(:follow) { 'content I created' }
      it { is_expected.to eq '[[*all+content I created]]'}
    end    
    context 'for a type card+follow option card' do
      let(:follow) { 'Basic+never' }
      it { is_expected.to eq '[[Basic+*type+never]]'}
    end
    context 'for a card+follow option card' do
      let(:follow) { 'No One Sees Me+never' }
      it { is_expected.to eq '[[No One Sees Me+*self+never]]'}
    end
    context 'for a card' do
      let(:follow) { 'No One Sees Me' }
      it { is_expected.to eq '[[No One Sees Me+*self+always]]'}
    end
  end
  
  describe 'event: update follow rule' do
    before do
      Card::Auth.current_id = Card['Joe User'].id
    end
    context 'when new entry added' do
      it 'adds new follow rule' do
        Card::Auth.as_bot do
          Card.create(:name=>"Joe User+*following", :content=>"[[No One Sees Me+*self+always]]")
        end
        expect( Card['No One Sees Me'].rule(:follow) ).to eq '[[always]]'
      end
    end
    context 'when entry changed' do
      it 'updates follow rule' do
        Card::Auth.as_bot do
          card = Card.create(:name=>"Joe User+*following", :content=>"[[No One Sees Me+*self+always]]") 
          card.update_attributes! :content=>"[[No One Sees Me+*self+never]]"
        end
        expect( Card['No One Sees Me'].rule(:follow) ).to eq '[[never]]'
      end
    end
    context 'when entry deleted' do
      it 'deletes follow rule' do
        Card::Auth.as_bot do
          card = Card.create(:name=>"Joe User+*following", :content=>"[[No One Sees Me+*self+always]]") 
          card.update_attributes! :content=>""
        end
        expect( Card['No One Sees Me'].rule_card(:follow) ).to eq nil
      end
    end 
    context 'when added special follow option' do
      it 'updates follow rule' do
        Card::Auth.as_bot do
          card = Card.create(:name=>"Joe User+*following", :content=>"[[No One Sees Me+*self+always]]") 
          card.update_attributes! :content=>"[[content I edited]]\n[[content I created]]"
        end
        expect( Card['*all+*follow+Joe User'].content).to eq "[[content I edited]]\n[[content I created]]"
      end
    end
  end
end