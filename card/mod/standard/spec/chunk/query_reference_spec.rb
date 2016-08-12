# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::QueryReference, "QueryReference" do
  context "syntax parsing" do
    before do
      @class = Card::Content::Chunk::QueryReference
    end

    let :query_refs do
      content = Card::Content.new @content, Card.new(type: "Search")
      content.find_chunks(Card::Content::Chunk::QueryReference)
    end

    subject { query_refs.first.name }

    it "handles simple search" do
      @content = '{"name":"Waldo"}'
      is_expected.to eq "Waldo"
    end

    it "handles operators" do
      @content = '{"name":["eq","Waldo"]}'
      is_expected.to eq "Waldo"
    end

    it "handles multiple values for operators" do
      @content = '{"name":["in","Where","Waldo"]}'
      expect(query_refs[1].name).to eq "Waldo"
    end

    it "handles plus attributes" do
      @content = '{"right_plus":["Waldo",{"content":"here"}]}'
      is_expected.to eq "Waldo"
    end

    it "handles nested query structures" do
      @content = '{"any":{"content":"Where", ' \
                 '"right_plus":["is",{"name":"Waldo"}]}}'
      expect(query_refs[0].name).to eq "Where"
      expect(query_refs[1].name).to eq "is"
      expect(query_refs[2].name).to eq "Waldo"
    end

    it "handles contextual names" do
      @content = '{"name":"_+Waldo"}'
      is_expected.to eq "_+Waldo"
    end
  end
end
