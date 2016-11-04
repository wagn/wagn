# -*- encoding : utf-8 -*-

describe Card::Set::All::AllCss do
  it "renders content view" do
    content = "#box { display: block }"
    rendered = render_card :content, { content: content }, format: :css
    #    rendered.should =~ /Style Card\:/
    expect(rendered).to match(/#{ Regexp.escape content }/)
  end
end
