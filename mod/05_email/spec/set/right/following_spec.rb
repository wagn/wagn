# -*- encoding : utf-8 -*-

describe Card::Set::Right::Following do
  describe '#make_name_valid_following_entry' do
    subject do 
      Card::Auth.as_bot { card = Card.new(:name=>"Joe User+*following").make_name_valid_following_entry(follow) } 
    end
    
    context 'for a set card' do
      let(:follow) { "No One Sees Me+*self"}
      it { is_expected.to eq 'No One Sees Me+*self+*follow+Joe User+always'}
    end   
    context 'for a type card' do
      let(:follow) { 'Basic' }
      it { is_expected.to eq 'Basic+*type+*follow+Joe User+always'}
    end    
    context 'for a follow option card' do
      let(:follow) { 'content I created' }
      it { is_expected.to eq '*all+*follow+Joe User+content I created'}
    end    
    context 'for a type card+follow option card' do
      let(:follow) { 'Basic+never' }
      it { is_expected.to eq 'Basic+*type+*follow+Joe User+never'}
    end
    context 'for a card+follow option card' do
      let(:follow) { 'No One Sees Me+never' }
      it { is_expected.to eq 'No One Sees Me+*self+*follow+Joe User+never'}
    end
    context 'for a card' do
      let(:follow) { 'No One Sees Me' }
      it { is_expected.to eq 'No One Sees Me+*self+*follow+Joe User+always'}
    end
  end
  
  describe 'event: update follow rule' do
    def follow option, args={}
      Card::Auth.as_bot do
        name = 'No One Sees Me'
        content = "[[#{name}+*self+*follow+Joe User+#{option}]]"
        Card::Env.params[:card] = { :content =>content }
        card = Card.create(:name=>"Joe User+*following", :content=>content)
        if args[:then]
          content = "[[#{name}+*self+*follow+Joe User+#{args[:then]}]]"
          Card::Env.params[:card] = { :content =>content }
          card.update_attributes! :content=>content
        end
      end
    end
    let (:follow_rule) { Card['No One Sees Me'].rule(:follow) }
    before do
      Card::Auth.current_id = Card['Joe User'].id
    end
    context 'when new entry added' do
      it 'adds new follow rule' do
        follow 'always'
        expect( follow_rule ).to eq '[[always]]'
      end
    end
    context 'when entry changed' do
      it 'updates follow rule' do
        follow 'always', :then=>'never'
        expect( follow_rule ).to eq '[[never]]'
      end
    end
    context 'when entry deleted' do
      it 'deletes follow rule' do
        follow 'always', :then=>'nothing'
        expect( follow_rule ).to eq nil
      end
    end 
    context 'when added special follow option' do
      it 'updates follow rule' do
        follow 'always', :then=>'content I edited'
        expect( follow_rule ).to eq "[[content I edited]]"
      end
    end
  end
end