# -*- encoding : utf-8 -*-

describe Wagn::Cache do
  describe "with nil store" do
    before do
      mock(Wagn::Cache).generate_cache_id.times(2).returns("cache_id")
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
      mock(Wagn::Cache).generate_cache_id().returns("cache_id")
      @cache = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    end

    it "#read" do
      mock(@store).read("prefix/cache_id/foo")
      @cache.read("foo")
    end

    it "#write" do
      mock(@store).write("prefix/cache_id/foo", "val")
      @cache.write("foo", "val")
      @cache.read('foo').should == "val"
    end

    it "#fetch" do
      block = Proc.new { "hi" }
      mock(@store).fetch("prefix/cache_id/foo", &block)
      @cache.fetch("foo", &block)
    end

    it "#delete" do
      mock(@store).delete("prefix/cache_id/foo")
      @cache.delete "foo"
    end

    it "#write_local" do
      @cache.write_local('a', 'foo')
      @cache.read("a").should == 'foo'
      mock.dont_allow(@store).write
      @cache.store.read("a").should == nil
    end
  end

  it "#reset" do
    mock(Wagn::Cache).generate_cache_id.returns("cache_id1")
    @store = ActiveSupport::Cache::MemoryStore.new
    @cache = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    @cache.prefix.should == "prefix/cache_id1/"
    @cache.write("foo","bar")
    @cache.read("foo").should == "bar"

    # reset
    mock(Wagn::Cache).generate_cache_id.returns("cache_id2")
    @cache.reset
    @cache.prefix.should == "prefix/cache_id2/"
    @cache.store.read("prefix/cache_id").should == "cache_id2"
    @cache.read("foo").should be_nil

    cache2 = Wagn::Cache.new :store=>@store, :prefix=>"prefix"
    cache2.prefix.should == "prefix/cache_id2/"
  end

  describe "with file store" do
    before do
      cache_path = "#{Wagn.root}/tmp/cache"
      @store = ActiveSupport::Cache::FileStore.new cache_path

      @store.clear
      #cache_path = cache_path + "/prefix"
      #p = Pathname.new(cache_path)
      #p.mkdir if !p.exist?
      #
      #root_dirs = Dir.entries(cache_path).reject{|f| ['.', '..'].include?(f)}
      #files_to_remove = root_dirs.collect{|f| File.join(cache_path, f)}
      #FileUtils.rm_r(files_to_remove)

      mock(Wagn::Cache).generate_cache_id.times(2).returns("cache_id1")
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
