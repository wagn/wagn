# -*- encoding : utf-8 -*-

describe Card::Chunk::EscapedLiteral, "literal chunk tests" do

  it "should handle escaped link" do
    render_content('write this: \[[text]]').should == 'write this: <span>[</span>[text]]'
  end

  it "should handle escaped inclusion" do
    render_content('write this: \{{cardname}}').should == 'write this: <span>{</span>{cardname}}'
  end

end

