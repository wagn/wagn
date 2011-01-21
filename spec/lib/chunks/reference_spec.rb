require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Reference" do
  
  describe "link renderer" do
    it "should render links" do
      Chunk::Reference.standard_card_link('A').should== %{<a class="known-card" href="/wagn/A">A</a>}
      Chunk::Reference.standard_card_link('A').should== %{<a class="known-card" href="/wagn/A">A</a>}
    end
  end
  
end