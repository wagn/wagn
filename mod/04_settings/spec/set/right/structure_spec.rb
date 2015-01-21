# -*- encoding : utf-8 -*-

describe Card::Set::Right::Structure do
  it "closed_content is rendered as type + raw" do
    template = Card.new(:name=>'A+*right+*structure', :content=>'[[link]] {{inclusion}}')
    expect(template.format._render(:closed_content)).to eq(
      '<a class="cardtype known-card" href="/Basic">Basic</a> : [[link]] {{inclusion}}'
    )
  end

  it "closed_content is rendered as type + raw" do
    template = Card.new(:name=>'A+*right+*structure', :type=>'Html', :content=>'[[link]] {{inclusion}}')
    expect(template.format._render(:closed_content)).to eq(
      '<a class="cardtype known-card" href="/HTML">HTML</a> : [[link]] {{inclusion}}'
    )
  end
end
