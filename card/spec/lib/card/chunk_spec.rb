# -*- encoding : utf-8 -*-
require "card/content/chunk"

describe Card::Content::Chunk, "Chunk" do
  context "Class" do
    it "should populate prefix map on load" do
      expect(Card::Content::Chunk.prefix_map_by_list[:default].keys.size)
        .to be > 0
      expect(Card::Content::Chunk.prefix_map_by_list[:default]["{"][:class])
        .to eq(Card::Content::Chunk::Include)
    end

    it "should find Chunk classes using matched prefix" do
      expect(Card::Content::Chunk.find_class_by_prefix("{{"))
        .to eq(Card::Content::Chunk::Include)
    end
  end
end
