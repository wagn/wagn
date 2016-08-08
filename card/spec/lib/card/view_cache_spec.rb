describe Card::ViewCache do
  it "gets cleared by Card::Cache.reset_all" do
    Card::ViewCache.cache.write "testkey", 1
    expect(Card::ViewCache.cache.exist? "testkey").to be_truthy
    Card::Cache.reset_all
    expect(Card::ViewCache.cache.exist? "testkey").to be_falsey
  end
end
