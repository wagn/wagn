# -*- encoding : utf-8 -*-

describe Card::Auth do
  before do
    Card::Auth.current_id = Card::AnonymousID
    @joeuserid = Card["Joe User"].id
  end

  it "authenticates user" do
    authenticated = Card::Auth.authenticate "joe@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "authenticates user despite whitespace" do
    authenticated = Card::Auth.authenticate " joe@user.com ", " joe_pass "
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "authenticates user with weird email capitalization" do
    authenticated = Card::Auth.authenticate "JOE@user.com", "joe_pass"
    expect(authenticated.left_id).to eq(@joeuserid)
  end

  it "sets current directly from email" do
    Card::Auth.current= "joe@user.com"
    expect(Card::Auth.current_id).to eq(@joeuserid)
  end

  it "sets current directly from id when mark is id" do
    Card::Auth.current= @joeuserid
    expect(Card::Auth.current_id).to eq(@joeuserid)
  end

  it "sets current directly from id when mark is id" do
    Card::Auth.current= @joeuserid
    expect(Card::Auth.current_id).to eq(@joeuserid)
  end

  context "with token" do
    before do
      @joeadmin = Card["Joe Admin"]
      @token = "abcd"
      Card::Auth.as_bot do
        @joeadmin.account.token_card.update_attributes! content: @token
      end
    end

    it "sets current from token" do
      Card::Auth.set_current_from_token @token
      expect(Card::Auth.current_id).to eq(@joeadmin.id)
    end

    it "sets arbitrary current from token on authorized account" do
      Card::Auth.set_current_from_token @token, @joeuserid
      expect(Card::Auth.current_id).to eq(@joeuserid)
    end
  end
end
