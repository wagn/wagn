# -*- encoding : utf-8 -*-

describe Card::View do
  it "cache gets cleared by Card::Cache.reset_all" do
    Card::View.cache.write "testkey", 1
    expect(Card::View.cache.exist? "testkey").to be_truthy
    Card::Cache.reset_all
    expect(Card::View.cache.exist? "testkey").to be_falsey
  end
end
