# -*- encoding : utf-8 -*-

describe Card::Set::Right::Token do
  before do
    @token = Card["Anonymous+*account"].fetch trait: :token, new: {}
  end

  it "should get expiration from configuration by default" do
    expect(@token.term).to eq(Card.config.token_expiry)
  end

  it "should get expiration from card if it exists" do
    @token.expiration = "3 days"
    expect(@token.term).to eq(3.days)
    expect(@token.permanent?).to be false
  end

  it 'should be permanent if expiration is "none"' do
    @token.expiration = "none"
    expect(@token.term).to eq("permanent")
    expect(@token.permanent?).to be true
  end
end
