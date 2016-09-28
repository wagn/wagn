# -*- encoding : utf-8 -*-

describe Card::Cache::ViewCache do
  it "gets cleared by Card::Cache.reset_all" do
    Card::Cache::ViewCache.cache.write "testkey", 1
    expect(Card::Cache::ViewCache.cache.exist? "testkey").to be_truthy
    Card::Cache.reset_all
    expect(Card::Cache::ViewCache.cache.exist? "testkey").to be_falsey
  end
end
