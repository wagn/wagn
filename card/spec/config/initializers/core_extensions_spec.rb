describe Hash do
  describe "new_nested" do
    it "creates nested hashes" do
      nested_hash = Hash.new_nested Hash, Hash
      expect(nested_hash[:a]).to be_instance_of Hash
      expect(nested_hash[:a][:b]).to be_instance_of Hash
      expect(nested_hash[:d][:c]).to be_instance_of Hash
    end

    it "creates set in hash" do
      nested_hash = Hash.new_nested ::Set
      expect(nested_hash[:a]).to be_instance_of ::Set
    end
  end
end
