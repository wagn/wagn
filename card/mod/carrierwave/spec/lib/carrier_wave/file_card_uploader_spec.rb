# -*- encoding : utf-8 -*-

describe CarrierWave::FileCardUploader do
  subject do
    Card[:logo]
  end
  describe "#db_content" do
    it "returns correct identifier" do
      expect(subject.db_content)
        .to eq "#{}
    end
  end
end
