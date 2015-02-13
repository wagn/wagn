# -*- encoding : utf-8 -*-

describe Card::Chunk::EscapedLiteral, "literal chunk tests" do

  it "should handle escaped link" do
    expect(render_content('write this: \[[text]]')).to eq('write this: <span>[</span>[text]]')
  end

  it "should handle escaped inclusion" do
    expect(render_content('write this: \{{cardname}}')).to eq('write this: <span>{</span>{cardname}}')
  end

end

