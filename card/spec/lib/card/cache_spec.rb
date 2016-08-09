# -*- encoding : utf-8 -*-

describe Card::Cache do
  describe "with nil store" do
    before do
      @cache = Card::Cache.new prefix: "prefix"
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
      @hard = ActiveSupport::Cache::MemoryStore.new
      @cache = Card::Cache.new store: @hard
      @prefix = @cache.hard.prefix
    end

    it "#read" do
      expect(@hard).to receive(:read).with("#{@prefix}/foo")
      @cache.read("foo")
    end

    it "#write" do
      expect(@hard).to receive(:write).with("#{@prefix}/foo", "val")
      @cache.write("foo", "val")
      expect(@cache.read("foo")).to eq("val")
    end

    it "#fetch" do
      block = proc { "hi" }
      expect(@hard).to receive(:fetch).with("#{@prefix}/foo", &block)
      @cache.fetch("foo", &block)
    end

    it "#delete" do
      expect(@hard).to receive(:delete).with("#{@prefix}/foo")
      @cache.delete "foo"
    end

    it "#soft.write" do
      @cache.soft.write("a", "foo")
      expect(@cache.read("a")).to eq("foo")
      expect(@hard).not_to receive(:write)
      expect(@cache.hard.read("a")).to eq(nil)
    end
  end

  it "#reset" do
    @hard = ActiveSupport::Cache::MemoryStore.new
    @cache = Card::Cache.new store: @hard, database: "mydb"

    expect(@cache.hard.prefix).to match(/^mydb\//)
    @cache.write("foo", "bar")
    expect(@cache.read("foo")).to eq("bar")


    # reset
    @cache.reset
    expect(@cache.hard.prefix).to match(/^mydb\//)
    expect(@cache.read("foo")).to be_nil

    cache2 = Card::Cache.new store: @hard, database: "mydb"
    expect(cache2.hard.prefix).to match(/^mydb\//)
  end

  describe "with file store" do
    before do
      cache_path = "#{Wagn.root}/tmp/cache"
      FileUtils.mkdir_p(cache_path) unless File.directory?(cache_path)
      @hard = ActiveSupport::Cache::FileStore.new cache_path

      @hard.clear
      # cache_path = cache_path + '/prefix'
      # p = Pathname.new(cache_path)
      # p.mkdir if !p.exist?
      #
      # root_dirs = Dir.entries(cache_path).reject{|f| ['.', '..'].include?(f)}
      # files_to_remove = root_dirs.collect{|f| File.join(cache_path, f)}
      # FileUtils.rm_r(files_to_remove)
      @cache = Card::Cache.new store: @hard, prefix: "prefix"
    end

    describe "#basic operations with special symbols" do
      it "should work" do
        @cache.write('%\\/*:?"<>|', "foo")
        cache2 = Card::Cache.new store: @hard, prefix: "prefix"
        expect(cache2.read('%\\/*:?"<>|')).to eq("foo")
        @cache.reset
      end
    end

    describe "#basic operations with non-latin symbols" do
      it "should work" do
        @cache.write("(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén", "foo")
        @cache.write("русский", "foo")
        cache3 = Card::Cache.new store: @hard, prefix: "prefix"
        cached = cache3.read "(汉语漢語 Hànyǔ; 华语華語 Huáyǔ; 中文 Zhōngwén"
        expect(cached).to eq("foo")
        expect(cache3.read("русский")).to eq("foo")
        @cache.reset
      end
    end

    describe "#tempfile" do
      # TODO
    end
  end
end
