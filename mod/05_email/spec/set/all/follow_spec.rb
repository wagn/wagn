# -*- encoding : utf-8 -*-

describe "Card::Set::All::Follow" do
  def follow_view card_name
    render_card :follow, :name=>card_name
  end
   
  describe "follower_ids" do
    
    context 'when a new +*follow rule created' do
      it 'contains id of a new follower' do
        Card::Auth.as_bot do
          Card['Joe User'].follow "No One Sees Me"
          expect(Card['No One Sees Me'].follower_ids).to eq ::Set.new([Card['Joe User'].id])
        end
      end
    end
    
    
    subject { Card[cardname].follower_names.sort }
    context 'followers of No One Sees Me' do
      let(:cardname) {'No One Sees Me'}
      it { is_expected.to eq([]) }
    end
    
    context 'followers of Magnifier' do
      let(:cardname) {'Magnifier'} 
      it { is_expected.to eq([])}
    end
    
    context 'followers of Magnifier+lens' do
      let(:cardname) {'Magnifier+lens'} 
      it { is_expected.to eq ['Big Brother','Narcissist']}
    end
    
    context 'followers of Sunglasses' do
      let(:cardname) {'Sunglasses'} 
      it { is_expected.to eq ['Big Brother', 'Narcissist', 'Optic fan', 'Sara', 'Sunglasses fan']}
    end
    context 'followers of Sunglasses+tint' do
      let(:cardname) {'Sunglasses+tint'} 
      it { is_expected.to eq ['Big Brother', 'Narcissist', 'Optic fan', 'Sara', 'Sunglasses fan']}
    end
    
    context 'followers of Google glass' do
      let(:cardname) {'Google glass'} 
      it { is_expected.to eq ['Big Brother', 'Optic fan', 'Sara']}
    end
  end




   
  describe "view: follow" do
    before do
      Card::Auth.current_id = Card['Big Brother'].id
    end
      
    def assert_following_view name, args
      assert_follow_view name, args.reverse_merge(:following => true, :text=>"following #{name}")
    end
  
#  href="/card/update/Home+*self+philipp+*follow?card%5Bcontent%5D=%5B%5Bnever%5D%5D&success%5Bid%5D=Home&success%5Bview%5D=follow"
    def assert_follow_view name, args
      href = "/card/update/#{args[:add_set].to_name.url_key}+Big_Brother+*follow?"
      href += CGI.escape("card[content]") + '='
      href += 
        if args[:following] 
          link_class = "watch-toggle-off"
          CGI.escape("[[never]]")
        else
          link_class = "watch-toggle-on"
          CGI.escape("[[always]]")
        end
        binding.pry
      assert_view_select follow_view(name), 'div[class~="card-slot follow-view"]' do
        assert_select "a[class~=#{link_class}][href*='#{href}']", args[:text] || "follow #{name}"
      end
    end

      
    context "when not following" do
      it 'renders follow link' do
        assert_follow_view 'No One Sees Me', :add_set=>'No One Sees Me+*self'
      end
    end

    context "when following *self" do
      it 'renders following link' do
        assert_following_view 'Look At Me', :add_set=>'Look at me+*self'
      end
    end
  
    context "when following *type" do
      it 'renders following link' do
        assert_following_view 'Sunglasses', :add_set=>'Sunglasses+*self'
      end
    end
    
    context "when following cardtype card" do
      it 'renders following link' do
        assert_following_view 'Optic', :add_set=>'Optic+*type'
      end
    end
    
    context "when not following cardtype card" do
      it "renders 'follow all' link" do
        assert_follow_view 'Basic', :add_set=>'Basic+*type', :text=>"follow all"
      end
    end
  
    context "when following *right" do
      it "renders following link" do
        assert_following_view 'Magnifier+lens', :add_set=>'Magnifier+lens+*self'
      end
    end
  
    context 'when following "content I created"' do
      before { Card::Auth.current_id = Card['Narcissist'].id }
      it "renders following link" do
        assert_following_view 'Sunglasses', :add_set=>'Sunglasses+*self'
      end
    end
  
    context 'when following "content I edited"' do
      before { Card::Auth.current_id = Card['Narcissist'].id }
      it "renders following link" do
        assert_following_view 'Magnifier+lens', :add_set=>'Magnifier+lens+*self'
      end
    end
  end
  
  
  describe "view: follow_menu" do
    before do
      Card::Auth.current_id = Card['Big Brother'].id
    end
    
    
    
    def follow_menu card_name
      render_card :follow_menu, :name=>card_name
    end
    
    
    it 'first entry is following link' do
      link_class = "watch-toggle-off"
      add_item   =  CGI.escape("Look at me+*self+never")
      assert_view_select follow_menu("Look At Me")[0][:raw], 'div[class~="card-slot follow_link-view"]' do
        assert_select "a[class~=#{link_class}][href*='add_item=#{add_item}']", 'following'
      end
    end

    it 'second entry is link to advanced options' do 
      assert_view_select follow_menu("Look At Me")[1][:raw], 'div[class~="card-slot follow_link-view"]' do
        assert_select 'a', 'advanced...'
      end
    end
    
    
     #
    # def add_items array
    #   array.map do |entry|
    #     entry[:raw].scan(/add_item=([^&]+)&/) do |match|
    #       CGI.unescape(match.first)
    #     end
    #   end
    # end
    #
    # def drop_items array
    #   array.map do |entry|
    #     entry[:raw].scan(/drop_item=([^&]+)&/) do |match|
    #       CGI.unescape(match.first)
    #     end
    #   end
    # end
    #
    # def includes_follow_link text
    #   expect(add_items(subject)).to include text
    # end
    #
    # def includes_unfollow_link text
    #   expect(drop_items(subject)).to include text
    # end
    #
    #
    # context "when following Optic+*type" do
    #   before  { Card::Auth.current_id = Card['Optic fan'].id }
    #   subject { follow_menu 'Sunglasses' }
    #   it { includes_unfollow_link "Optic+*type" }
    #   it { includes_follow_link "Sunglasses+*self" }
    #   it { is_expected.not_to include "content_I_created"}
    #   it { is_expected.not_to include "content_I_edited"}
    # end
    #
    # context "for card created by user" do
    #   context "when following 'content I created' " do
    #     before  { Card::Auth.current_id = Card['Narcissist'].id }
    #     subject { follow_menu 'Sunglasses' }
    #     it      { includes_unfollow_link "content_I_created" }
    #   end
    #   context "when not following 'content I created' " do
    #     before  { Card::Auth.current_id = Card['Optic fan'].id }
    #     subject { follow_menu 'Google glass' }
    #     it      { includes_follow_link "content_I_created" }
    #   end
    # end
    #
    # context "for card edited by user" do
    #   before  { Card::Auth.current_id = Card['Narcissist'].id }
    #   subject { follow_menu 'Magnifier+lens+*self' }
    #   it      { includes_unfollow_link "content_I_edited" }
    # end
    #
    # context "when following *right" do
    #   subject { follow_menu 'Magnifier+lens' }
    #   it      { includes_unfollow_link "lens+*right"}
    #   it      { includes_follow_link "Optic+lens+*type_plus_right"}
    # end
    #
    # context "when following several sets" do
    #   subject { follow_menu 'Sunglasses+lens' }
    #   it      { includes_unfollow_link "lens+*right"}
    #   it      { includes_unfollow_link "Optic+*type"}
    #   it      { includes_unfollow_link "Sunglasses"}
    # end
  end
 
end