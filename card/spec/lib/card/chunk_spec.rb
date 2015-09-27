# -*- encoding : utf-8 -*-
require 'card/chunk'

describe Card::Chunk, "Chunk" do
  context "Class" do
    it "should populate prefix map on load" do
      expect(Card::Chunk.prefix_map.keys.size).to be > 0
      expect(Card::Chunk.prefix_map['{'][:class]).to eq(Card::Chunk::Include)
    end
    
    it "should find Chunk classes using matched prefix" do
      expect(Card::Chunk.find_class_by_prefix('{{')).to eq(Card::Chunk::Include)
    end
    
  end
  
end