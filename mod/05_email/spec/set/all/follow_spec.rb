# -*- encoding : utf-8 -*-

describe "Card::Set::All::Follow" do
  def follow_view card_name
    render_card :follow, :name=>card_name
  end
   
  describe "follower_ids" do
    context 'when a new +*following entry created' do
      it 'contains id of a new follower' do
        Card::Auth.as_bot do
          Card.create :name=>"Joe User+*following", :content=>"[[No One Sees Me+*self+always]]"
          expect(Card['No One Sees Me'].follower_ids).to eq ::Set.new([Card['Joe User'].id])
        end
      end
    end
  end
   
  describe "view: follow" do
    before do
      Card::Auth.current_id = Card['Big Brother'].id
    end
      
      
    context "when not following" do
      subject { follow_view 'No One Sees Me' }
      it { is_expected.to eq "follow" }
    end

    context "when following *self" do
      subject { follow_view 'Look At Me' }    
      it { is_expected.to eq "following" }
    end
  
    context "when following *type" do
      subject { follow_view 'Sunglasses' }    
      it { is_expected.to eq "following" }
    end
  
    context "when following *right" do
      subject { follow_view 'Magnifier+lens' }    
      it { is_expected.to eq "following" }
    end
  
    context 'when following "content I created"' do
      before { Card::Auth.current_id = Card['Narcissist'].id }
      subject { follow_view 'Sunglasses' }    
      it { is_expected.to eq "following" }
    end
  
    context 'when following "content I edited"' do
      before { Card::Auth.current_id = Card['Narcissist'].id }
      subject { follow_view 'Magnifier+lens' }    
      it { is_expected.to eq "following" }
    end
  end
  
  
  describe "view: follow_menu" do
    before do
      Card::Auth.current_id = Card['Big Brother'].id
    end
    
    def follow_menu card_name
      render_card :follow_menu, :name=>card_name
    end
    
    def add_items array
      array.map do |entry|
        entry[:raw].scan(/add_item=([^&]+)&/) do |match|
          CGI.unescape(match.first)
        end
      end
    end
    
    def drop_items array
      array.map do |entry|
        entry[:raw].scan(/drop_item=([^&]+)&/) do |match|
          CGI.unescape(match.first)
        end
      end
    end
    
    def includes_follow_link text
      expect(add_items(subject)).to include text
    end
    
    def includes_unfollow_link text
      expect(drop_items(subject)).to include text
    end

    
    context "when following Optic+*type" do
      before  { Card::Auth.current_id = Card['Optic fan'].id }
      subject { follow_menu 'Sunglasses' }
      it { includes_unfollow_link "Optic+*type" }
      it { includes_follow_link "Sunglasses+*self" }
      it { is_expected.not_to include "content_I_created"}
      it { is_expected.not_to include "content_I_edited"}
    end

    context "for card created by user" do
      context "when following 'content I created' " do
        before  { Card::Auth.current_id = Card['Narcissist'].id }
        subject { follow_menu 'Sunglasses' }
        it      { includes_unfollow_link "content_I_created" }
      end
      context "when not following 'content I created' " do
        before  { Card::Auth.current_id = Card['Optic fan'].id }
        subject { follow_menu 'Google glass' }
        it      { includes_follow_link "content_I_created" }
      end
    end
    
    context "for card edited by user" do
      before  { Card::Auth.current_id = Card['Narcissist'].id }
      subject { follow_menu 'Magnifier+lens+*self' }
      it      { includes_unfollow_link "content_I_edited" }
    end
  
    context "when following *right" do
      subject { follow_menu 'Magnifier+lens' }
      it      { includes_unfollow_link "lens+*right"}
      it      { includes_follow_link "Optic+lens+*type_plus_right"}
    end
  
    context "when following several sets" do
      subject { follow_menu 'Sunglasses+lens' }
      it      { includes_unfollow_link "lens+*right"}
      it      { includes_unfollow_link "Optic+*type"}
      it      { includes_unfollow_link "Sunglasses"}
    end
  end
 
end