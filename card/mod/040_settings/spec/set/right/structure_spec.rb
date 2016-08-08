# -*- encoding : utf-8 -*-

describe Card::Set::Right::Structure do
  it "closed_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:closed_content)).to eq(
      '<a class="cardtype known-card" href="/Basic">Basic</a>' \
      " : [[link]] {{nest}}"
    )
  end

  it "closed_content is rendered as type + raw" do
    template = Card.new name: "A+*right+*structure", type: "Html",
                        content: "[[link]] {{nest}}"
    expect(template.format._render(:closed_content)).to eq(
      '<a class="cardtype known-card" href="/HTML">HTML</a> : [[link]] {{nest}}'
    )
  end

  # it 'renders core as raw' do
  #     trs = Card.fetch('*type+*right+*structure').format.render_core
  #     expect(trs).to eq '{"type":"_left"}'
  # end
end
