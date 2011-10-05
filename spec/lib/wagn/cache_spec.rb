# encoding: utf-8
require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Wagn::Cache do
  describe "with nil store" do
    before do
      Wagn::Cache.should_receive("generate_cache_id").twice.and_return("cache_id")
      @cache = Wagn::Cache.new :prefix=>"prefix"
    end

    describe "#basic operations" do
      it "should work" do
        @cache.write("a", "foo")
        @cache.read("a").should == "foo"
        @cache.fetch("b") { "bar" }
        @cache.read("b").should == "bar"
        @cache.reset
      end
    end
  end

  describe "with same cache_id" do
    before :each do
      @store = ActiveSupport::Cache::MemoryStore.new
      Wagn::Cache.should_receive("generate_cache_id").and_return("cache_id")
      @cache = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    end

    it "#read" do
      @store.should_receive(:read).with("prefix/cache_id/foo")
      @cache.read("foo")
    end

    it "#write" do
      @store.should_receive(:write).with("prefix/cache_id/foo", "val")
      @cache.write("foo", "val")
      @cache.read('foo').should == "val"
    end

    it "#fetch" do
      block = Proc.new { "hi" }
      @store.should_receive(:fetch).with("prefix/cache_id/foo", &block)
      @cache.fetch("fetch", &block)
    end

    it "#delete" do
      @store.should_receive(:delete).with("prefix/cache_id/foo")
      @cache.delete "foo"
    end

    it "#write_local" do
      @cache.write_local('a', 'foo')
      @cache.read("a").should == 'foo'
      @store.should_not_receive(:write)
      @cache.store.read("a").should == nil
    end
  end

  it "#reset" do
    Wagn::Cache.should_receive("generate_cache_id").and_return("cache_id1")
    @store = ActiveSupport::Cache::MemoryStore.new
    @cache = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    @cache.prefix.should == "prefix/cache_id1/"
    @cache.write("foo","bar")
    @cache.read("foo").should == "bar"

    # reset
    Wagn::Cache.should_receive("generate_cache_id").and_return("cache_id2")
    @cache.reset
    @cache.prefix.should == "prefix/cache_id2/"
    @cache.store.read("prefix/cache_id").should == "cache_id2"
    @cache.read("foo").should be_nil

    cache2 = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    cache2.prefix.should == "prefix/cache_id2/"
  end

  describe "with file store" do
    before do
      cache_path = "#{RAILS_ROOT}/tmp/cache"
      @store = ActiveSupport::Cache::FileStore.new cache_path

      # TODO @store.clear
      cache_path = cache_path + "/prefix"
      p = Pathname.new(cache_path)
      p.mkdir if !p.exist?

      root_dirs = Dir.entries(cache_path).reject{|f| ['.', '..'].include?(f)}
      files_to_remove = root_dirs.collect{|f| File.join(cache_path, f)}
      FileUtils.rm_r(files_to_remove)
      
      Wagn::Cache.should_receive("generate_cache_id").twice.and_return("cache_id1")
      @cache = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    end

    describe "#basic operations with special symbols" do
      it "should work" do
        @cache.write('%\\/*:?"<>|', "foo")
        cache2 = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
        cache2.read('%\\/*:?"<>|').should == "foo"
        @cache.reset
      end
    end

    describe "#basic operations with non-latin symbols" do
      it "should work" do
        @cache.write('(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén', "foo")
        @cache.write('русский', "foo")
        cache3 = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
        cache3.read('(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén').should == "foo"
        cache3.read('русский').should == "foo"
        @cache.reset
      end
    end

    describe "#tempfile" do
      # TODO
    end
  end
end