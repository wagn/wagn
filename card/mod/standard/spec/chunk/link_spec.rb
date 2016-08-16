# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::Link do
  def assert_link target, args
    text = args.delete(:text)
    format_args = args.delete(:format_args)
    assert_args = ["a"]
    args.each_pair do |key, val|
      assert_args[0] << "[#{key}=\"#{val}\"]"
    end
    assert_args << { text: text } if text
    assert_view_select render_content(target, (format_args || {})), *assert_args
  end

  it "handles unknown cards" do
    assert_link "[[Nixon]]", class: "wanted-card", href: "/Nixon", text: "Nixon"
  end

  it "handles known cards" do
    assert_link "[[A]]", class: "known-card", href: "/A", text: "A"
  end

  it "handles custom text" do
    assert_link "[[Baines|Lyndon]]", class: "wanted-card", href: "/Baines",
                                     text: "Lyndon"
  end

  it "handles relative names" do
    @card = Card.new name: "Kennedy"
    assert_link "[[+Monroe]]", class: "wanted-card",
                               href: "/Kennedy+Monroe",
                               text: "Kennedy+Monroe"
    assert_link "[[_self+Exner]]", class: "wanted-card",
                                   href: "/Kennedy+Exner",
                                   text: "Kennedy+Exner"
    assert_link "[[Onassis+]]", class: "wanted-card",
                                href: "/Onassis+Kennedy",
                                text: "Onassis+Kennedy"
  end

  it "handles relative names in context" do
    @card = Card.new name: "Kennedy"
    format_args = { context_names: ["Kennedy".to_name] }
    assert_link "[[+Monroe]]", format_args: format_args,
                               class: "wanted-card",
                               href: "/Kennedy+Monroe",
                               text: "+Monroe"
    assert_link "[[_self+Exner]]", format_args: format_args,
                                   class: "wanted-card",
                                   href: "/Kennedy+Exner",
                                   text: "+Exner"
    assert_link "[[Onassis+]]", format_args: format_args,
                                class: "wanted-card",
                                href: "/Onassis+Kennedy",
                                text: "Onassis"
  end

  it "handles relative urls" do
    assert_link "[[/recent]]", class: "internal-link",
                               href: "/recent",
                               text: "/recent"
  end

  it "handles absolute urls" do
    assert_link "[[http://google.com]]",
                class: "external-link", target: "_blank",
                href: "http://google.com", text: "http://google.com"
  end

  it "should escape spaces in cardnames with %20 (not +)" do
    assert_link '[[Marie "Mad Dog" Deatherage|Marie]]',
                class: "wanted-card",
                href: "/Marie_Mad_Dog_Deatherage" \
                      "?card%5Bname%5D=Marie+%22Mad+Dog%22+Deatherage",
                text: "Marie"
  end

  it "doesn't escape content outside of link" do
    content =
      render_content "wgw&nbsp; [[http://www.google.com|google]] &nbsp;  <br>"
    expect(content).to eq(
      'wgw&nbsp; <a target="_blank" class="external-link" ' \
      'href="http://www.google.com">google</a> &nbsp;  <br>'
    )
  end

  it "handles nests in link text" do
    assert_link "[[linkies|{{namies|name}}]]",
                class: "wanted-card", href: "/linkies", text: "namies"
  end

  it "handles dot (.) in missing cardlink" do
    assert_link "[[Wagn 1.10.12]]",
                class: "wanted-card",
                href: "/Wagn_1_10_12?card%5Bname%5D=Wagn+1.10.12",
                text: "Wagn 1.10.12"
  end
end
