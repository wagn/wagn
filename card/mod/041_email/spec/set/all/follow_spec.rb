# -*- encoding : utf-8 -*-

describe "Card::Set::All::Follow" do
  def follow_view card_name
    render_card :follow_link, name: card_name
  end

  describe "follower_ids" do
    context "when a new +*follow rule created" do
      it "contains id of a new follower" do
        Card::Auth.as_bot do
          Card["Joe User"].follow "No One Sees Me"
          expect(Card["No One Sees Me"].follower_ids)
            .to eq ::Set.new([Card["Joe User"].id])
        end
      end
    end

    subject { Card[cardname].follower_names.sort }
    context "followers of No One Sees Me" do
      let(:cardname) { "No One Sees Me" }
      it { is_expected.to eq([]) }
    end

    context "followers of Magnifier" do
      let(:cardname) { "Magnifier" }
      it { is_expected.to eq([]) }
    end

    context "followers of Magnifier+lens" do
      let(:cardname) { "Magnifier+lens" }
      it { is_expected.to eq ["Big Brother", "Narcissist"] }
    end

    context "followers of Sunglasses" do
      let(:cardname) { "Sunglasses" }
      it { is_expected.to eq ["Big Brother", "Narcissist", "Optic fan", "Sara", "Sunglasses fan"] }
    end
    context "followers of Sunglasses+tint" do
      let(:cardname) { "Sunglasses+tint" }
      it { is_expected.to eq ["Big Brother", "Narcissist", "Optic fan", "Sara", "Sunglasses fan"] }
    end

    context "followers of Google glass" do
      let(:cardname) { "Google glass" }
      it { is_expected.to eq ["Big Brother", "Optic fan", "Sara"] }
    end
  end

  describe "view: follow_link" do
    before do
      Card::Auth.current_id = Card["Big Brother"].id
    end

    def assert_following_view name, args
      assert_follow_view name,
                         args.reverse_merge(following: true, text: "unfollow")
    end

    #  href="/card/update/Home+*self+philipp+*follow?"\
    #       "card%5Bcontent%5D=%5B%5Bnever%5D%5D&"\
    #       "success%5Bid%5D=Home&success%5Bview%5D=follow"
    def assert_follow_view name, args
      args[:user] ||= "Big_Brother"
      #      href = "/card/update/#{args[:add_set].to_name.url_key}+"\
      #             "#{args[:user]}+*follow?"
      #      href += CGI.escape("card[content]") + '='
      #      href +=
      #        if args[:following]
      #          link_class = "follow-toggle-off"
      #          CGI.escape("[[*never]]")
      #        else
      #          link_class = "follow-toggle-on"
      #          CGI.escape("[[*always]]")
      #        end

      link_class = "follow-link"
      assert_view_select follow_view(name), "a[class~=#{link_class}][href*='']",
                         args[:text] || "follow"
    end

    context "when not following" do
      it "renders follow link" do
        assert_follow_view "No One Sees Me", add_set: "No One Sees Me+*self"
      end
    end

    context "when following *self" do
      it "renders following link" do
        assert_following_view "Look At Me", add_set: "Look at me+*self"
      end
    end

    context "when following *type" do
      it "renders following link" do
        assert_following_view "Sunglasses", add_set: "Sunglasses+*self"
      end
    end

    context "when following cardtype card" do
      it "renders following all link" do
        assert_following_view "Optic", add_set: "Optic+*type", text: "unfollow"
      end
    end

    context "when not following cardtype card" do
      it "renders 'follow all' link" do
        assert_follow_view "Basic", add_set: "Basic+*type", text: "follow"
      end
    end

    context "when following *right" do
      it "renders following link" do
        assert_following_view "Magnifier+lens", add_set: "Magnifier+lens+*self"
      end
    end

    context "when following content I created" do
      before { Card::Auth.current_id = Card["Narcissist"].id }
      it "renders following link" do
        assert_following_view "Sunglasses", add_set: "Sunglasses+*self",
                                            user: "Narcissist"
      end
    end

    context "when following content I edited" do
      before { Card::Auth.current_id = Card["Narcissist"].id }
      it "renders following link" do
        assert_following_view "Magnifier+lens", add_set: "Magnifier+lens+*self",
                                                user: "Narcissist"
      end
    end
  end
end
