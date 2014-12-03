# -*- encoding : utf-8 -*-

describe "Card::Set::All::Follow" do
  def follow_view card_name
    render_card :follow, :name=>card_name
  end
   
  describe "view: follow" do
    before do
      Card::Auth.current_user = Card['Big Brother']
    end
      
      
    context "when not following" do
      subject { follow_view 'No One Sees Me' 
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
      before { Card::Auth.current_user = Card['Narcissist'] }
      subject { follow_view 'Sunglasses' }    
      it { is_expected.to eq "following" }
    end
  
    context 'when following "content I edited"' do
      before { Card::Auth.current_user = Card['Narcissist'] }
      subject { follow_view 'Magnifier+lens' }    
      it { is_expected.to eq "following" }
    end
  end
  
  
  describe "view: follow_menu" do
    before do
      Card::Auth.current_user = Card['Big Brother']
    end
    
    def follow_menu card_name
      render_card :follow, :name=>card_name
    end
    
    def include_follow_link text
    end
    
    def include_unfollow_link texet
    end

    
    context "when following Optic+*type" do
      before  { Card::Auth.current_user = Card['Optic fan'] }
      subject { follow_menu 'Sunglasses' }
      it { is_expected.to include_unfollow_link "all Optics" }
      it { is_expected.to include_follow_link "Sunglasses" }
      it { is_expected.to not_include "content I created"}
      it { is_expected.to not_include "content I edited"}
    end

    context "for card created by user" do
      context "when following 'content I created' " do
        before  { Card::Auth.current_user = Card['Narcissist'] }
        subject { follow_menu 'Sunglasses' }
        it      { is_expected.to include_unfollow_link "content I created" }
      end
      context "when not following 'content I created' " do
        before  { Card::Auth.current_user = Card['Optic fan'] }
        subject { follow_menu 'Google glass' }
        it      { is_expected.to include_follow_link "content I created" }
      end
    end
    
    context "for card edited by user" do
      before  { Card::Auth.current_user = Card['Narcissist'] }
      subject { follow_menu 'Magnifier+lens' }
      it      { is_expected.to include_unfollow_link "content I edited" }
    end
  
    context "when following *right" do
      subject { follow_menu 'Magnifier+lens' }
      it      { is_expected.to include_unfollow_link "all +lens"}
      it      { is_expected.to include_follow_link "all Optic+lens"}
    end
  
    context "when following several sets" do
      subject { follow_menu 'Sunglasses+lens' }
      it      { is_expected.to include_unfollow_link "all +lens"}
      it      { is_expected.to include_unfollow_link "all Optics"}
      it      { is_expected.to include_unfollow_link "Sunglasses"}
    end
  end
 
end