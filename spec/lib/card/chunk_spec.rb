# -*- encoding : utf-8 -*-
require 'card/chunk'

describe Card::Chunk, "Chunk" do
  context "Class" do
    it "should populate prefix map on load" do
      Card::Chunk.prefix_map.keys.size.should > 0
      Card::Chunk.prefix_map['{'][:class].should == Card::Chunk::Include
    end
    
    it "should find Chunk classes using matched prefix" do
      Card::Chunk.find_class_by_prefix('{{').should == Card::Chunk::Include
    end
    
  end
  
end