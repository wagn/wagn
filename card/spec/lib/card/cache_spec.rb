# -*- encoding : utf-8 -*-

describe Card::Cache do
  describe "with nil store" do
    before do
      expect(Card::Cache).to receive(:generate_cache_id).exactly(2).times.and_return("cache_id")
      @cache = Card::Cache.new :prefix=>"prefix"
    end

    describe "#basic operations" do
      it "should work" do
        @cache.write("a", "foo")
        expect(@cache.read("a")).to eq("foo")
        @cache.fetch("b") { "bar" }
        expect(@cache.read("b")).to eq("bar")
        @cache.reset
      end
    end
  end

  describe "with same cache_id" do
    before :each do
      @store = ActiveSupport::Cache::MemoryStore.new
      expect(Card::Cache).to receive(:generate_cache_id).and_return("cache_id")
      @cache = Card::Cache.new :store=>@store, :prefix=>"prefix"
    end

    it "#read" do
      expect(@store).to receive(:read).with("prefix/cache_id/foo")
      @cache.read("foo")
    end

    it "#write" do
      expect(@store).to receive(:write).with("prefix/cache_id/foo", "val")
      @cache.write("foo", "val")
      expect(@cache.read('foo')).to eq("val")
    end

    it "#fetch" do
      block = Proc.new { "hi" }
      expect(@store).to receive(:fetch).with("prefix/cache_id/foo", &block)
      @cache.fetch("foo", &block)
    end

    it "#delete" do
      expect(@store).to receive(:delete).with("prefix/cache_id/foo")
      @cache.delete "foo"
    end

    it "#write_local" do
      @cache.write_local('a', 'foo')
      expect(@cache.read("a")).to eq('foo')
      expect(@store).not_to receive(:write)
      expect(@cache.store.read("a")).to eq(nil)
    end
  end

  it "#reset" do
    expect(Card::Cache).to receive(:generate_cache_id).and_return("cache_id1")
    @store = ActiveSupport::Cache::MemoryStore.new
    @cache = Card::Cache.new :store=>@store, :prefix=>"prefix"
    expect(@cache.prefix).to eq("prefix/cache_id1/")
    @cache.write("foo","bar")
    expect(@cache.read("foo")).to eq("bar")

    # reset
    expect(Card::Cache).to receive(:generate_cache_id).and_return("cache_id2")
    @cache.reset
    expect(@cache.prefix).to eq("prefix/cache_id2/")
    expect(@cache.store.read("prefix/cache_id")).to eq("cache_id2")
    expect(@cache.read("foo")).to be_nil

    cache2 = Card::Cache.new :store=>@store, :prefix=>"prefix"
    expect(cache2.prefix).to eq("prefix/cache_id2/")
  end

  describe "with file store" do
    before do
      cache_path = "#{Wagn.root}/tmp/cache"
      unless File.directory?(cache_path)
        FileUtils.mkdir_p(cache_path)
      end
      @store = ActiveSupport::Cache::FileStore.new cache_path

      @store.clear
      #cache_path = cache_path + "/prefix"
      #p = Pathname.new(cache_path)
      #p.mkdir if !p.exist?
      #
      #root_dirs = Dir.entries(cache_path).reject{|f| ['.', '..'].include?(f)}
      #files_to_remove = root_dirs.collect{|f| File.join(cache_path, f)}
      #FileUtils.rm_r(files_to_remove)

      expect(Card::Cache).to receive(:generate_cache_id).exactly(2).times.and_return("cache_id1")
      @cache = Card::Cache.new :store=>@store, :prefix=>"prefix"
    end

    describe "#basic operations with special symbols" do
      it "should work" do
        @cache.write('%\\/*:?"<>|', "foo")
        cache2 = Card::Cache.new :store=>@store, :prefix=>"prefix"
        expect(cache2.read('%\\/*:?"<>|')).to eq("foo")
        @cache.reset
      end
    end

    describe "#basic operations with non-latin symbols" do
      it "should work" do
        @cache.write('(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén', "foo")
        @cache.write('русский', "foo")
        cache3 = Card::Cache.new :store=>@store, :prefix=>"prefix"
        expect(cache3.read('(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén')).to eq("foo")
        expect(cache3.read('русский')).to eq("foo")
        @cache.reset
      end
    end

    describe "#tempfile" do
      # TODO
    end
  end
end
