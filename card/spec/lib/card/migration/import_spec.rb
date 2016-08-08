describe Card::Migration::Import do
  def meta_data
    path = Card::Migration::Import::ImportData::DEFAULT_PATH
    YAML.load_file(path).deep_symbolize_keys
  end

  def content_path filename
    File.join(Card::Migration::Import::ImportData::CARD_CONTENT_DIR, filename)
  end

  def content_data_file filename
    File.read content_path filename
  end

  before(:each) do
    if File.exist? Card::Migration::Import::ImportData::DEFAULT_PATH
      FileUtils.rm Card::Migration::Import::ImportData::DEFAULT_PATH
    end
    if Dir.exist? Card::Migration::Import::ImportData::CARD_CONTENT_DIR
      FileUtils.rm_rf Card::Migration::Import::ImportData::CARD_CONTENT_DIR
    end
  end

  describe ".add_remote" do
    it "adds remote to yml file" do
      Card::Migration::Import.add_remote "test", "url"
      remotes = meta_data[:remotes]
      expect(remotes[:test]).to eq "url"
    end
  end

  describe ".pull" do
    it "saves card attributes" do
      Card::Migration::Import.pull "A"
      cards = meta_data[:cards]
      expect(cards).to be_instance_of(Array)
      expect(cards.first[:name]).to eq "A"
      expect(cards.first[:type]).to eq "Basic"
    end

    it "saves card content" do
      Card::Migration::Import.pull "A"
      expect(content_data_file("a")).to eq "Alpha [[Z]]"
    end

    context "called with deep: true" do
      it "saves nested card" do
        Card::Migration::Import.pull "B", deep: true
        expect(content_data_file("z")).to eq "I'm here to be referenced to"
      end

      it "does not save linked card" do
        Card::Migration::Import.pull "A", deep: true
        expect(File.exist?(content_path("z"))).to be_falsey
      end

      it "saves pointer items" do
        Card::Migration::Import.pull "Fruit+*type+*create", deep: true
        expect(File.exist?(content_path("anyone"))).to be_truthy
      end
    end
  end

  describe ".merge" do
    it "updates card content" do
      Card::Migration::Import.pull "A"
      File.write content_path("a"), "test"
      Card::Migration::Import.merge
      expect(Card["A"].content).to eq "test"
    end
  end
end
