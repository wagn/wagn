# -*- encoding : utf-8 -*-

describe Card::Set::Type::Css do
  let(:css)                    { "#box { display: block }" }
  let(:compressed_css)         { "#box{display:block}\n" }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n" }

  it "should highlight code" do
    Card::Auth.as_bot do
      css_card = Card.create! name: "tmp css", type_code: "css",
                              content: "p { border: 1px solid black; }"
      assert_view_select css_card.format.render_core, "div[class=CodeRay]"
    end
  end

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) do
      Card.gimme! "test css", type: :css, content: css
    end
    let(:create_another_machine_input_card) do
      Card.gimme! "more test css", type: :css, content: css
    end
    let(:create_machine_card) do
      Card.gimme! "style with css+*style", type: :pointer
    end
    let(:card_content) do
      { in:         css,         out:         compressed_css,
        changed_in: changed_css, changed_out: compressed_changed_css }
    end
  end

  it_behaves_like "content machine", that_produces_css do
    let(:machine_card) { Card.gimme! "test css", type: :css, content: css }
    let(:card_content) do
      { in:         css,         out:         compressed_css,
        changed_in: changed_css, changed_out: compressed_changed_css }
    end
  end
end
