require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Wagn::Cache do
  describe "with same cache_id" do
    before :each do
      @store = ActiveSupport::Cache::MemoryStore.new
      Wagn::Cache::Main.should_receive("generate_cache_id").and_return("cache_id")
      @cache = Wagn::Cache::Main.new @store, "prefix"
    end

    it "reads" do
      @store.should_receive(:read).with("prefix/cache_id/foo")
      @cache.read("foo")
    end

    it "writes" do
      @store.should_receive(:write).with("prefix/cache_id/foo", "val")
      @cache.write("foo", "val")
    end

    it "fetches" do
      block = Proc.new { "hi" }
      @store.should_receive(:fetch).with("prefix/cache_id/foo", &block)
      @cache.fetch("fetch", &block)
    end

    it "deletes" do
      @store.should_receive(:delete).with("prefix/cache_id/foo")
      @cache.delete "foo"
    end
  end

  it "resets" do
    Wagn::Cache::Main.should_receive("generate_cache_id").and_return("cache_id1")
    @store = ActiveSupport::Cache::MemoryStore.new
    @cache = Wagn::Cache::Main.new @store, "prefix"
    @cache.write("foo","bar")
    @cache.read("foo").should == "bar"
    Wagn::Cache::Main.should_receive("generate_cache_id").and_return("cache_id2")
    @cache.reset
    @cache.read("foo").should be_nil
  end
end