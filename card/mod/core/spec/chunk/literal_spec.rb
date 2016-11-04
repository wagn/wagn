# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::EscapedLiteral, "literal chunk tests" do
  it "handles escaped link" do
    expect(render_content('write this: \[[text]]'))
      .to eq("write this: <span>[</span>[text]]")
  end

  it "handles escaped nest" do
    expect(render_content('write this: \{{cardname}}'))
      .to eq("write this: <span>{</span>{cardname}}")
  end
end
