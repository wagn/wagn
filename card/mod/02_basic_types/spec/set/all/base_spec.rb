# -*- encoding : utf-8 -*-
require "rspec-html-matchers"

describe Card::Set::All::Base do
  describe "handles view" do
    describe "name view" do
      it("name") { expect(render_card(:name)).to eq("Tempo Rary") }
      it "pluralizes" do
        name = render_content "{{Joe User|name; variant: plural}}"
        expect(name).to eq("Joe Users")
      end
      it "singularizes" do
        name = render_content "{{Sunglasses|name; variant: singular}}"
        expect(name).to eq("Sunglass")
      end
      it "handles more than one variant" do
        name = render_content(
          "{{Sunglasses|name; variant: singular, upcase}}"
        )
        expect(name).to eq("SUNGLASS")
      end
    end

    it("key") { expect(render_card(:key)).to eq("tempo_rary") }
    it("linkname") { expect(render_card(:linkname)).to eq("Tempo_Rary") }

    it "url" do
      Card::Env[:protocol] = "http://"
      Card::Env[:host]     = "eric.skippy.com"
      expect(render_card(:url)).to eq("http://eric.skippy.com/Tempo_Rary")
    end

    it :raw do
      @a = Card.new content: "{{A}}"
      expect(@a.format._render(:raw)).to eq("{{A}}")
    end

    it "core" do
      expect(render_card(:core, name: "A+B")).to eq("AlphaBeta")
    end

    it "core for new card" do
      expect(Card.new.format._render_core).to eq("")
    end

    describe "array" do
      it "of search items" do
        Card.create! name: "n+a", type: "Number", content: "10"
        sleep 1
        Card.create! name: "n+b", type: "Phrase", content: 'say:"what"'
        sleep 1
        Card.create! name: "n+c", type: "Number", content: "30"
        c = Card.new name: "nplusarray",
                     content: "{{n+*children+by create|array}}"
        expect(c.format._render(:core)).to eq(%(["10", "say:\\"what\\"", "30"]))
      end

      it "of pointer items" do
        Card.create! name: "n+a", type: "Number", content: "10"
        Card.create! name: "n+b", type: "Number", content: "20"
        Card.create! name: "n+c", type: "Number", content: "30"
        Card.create! name: "npoint", type: "Pointer",
                     content: "[[n+a]]\n[[n+b]]\n[[n+c]]"
        c = Card.new name: "npointArray", content: "{{npoint|array}}"
        expect(c.format._render(:core)).to eq(%(["10", "20", "30"]))
      end

      it "of basic items" do
        expect(render_card(:array, content: "yoing")).to eq(%(["yoing"]))
      end
    end
    it "renders template rule of embed cards based on set" do
      Card::Auth.as_bot
      content = "{{_left+test_another_card|content|content;"\
                "structure:test_another_card_structure}}"
      card = Card.create! name: "test_card+*right+*structure",
                          type_id: Card::HTMLID, content: content
      Card.create! name: "test_another_card+*right+*structure",
                   type_id: Card::SearchTypeID,
                   content: ' {"type":"basic","left":"_1"}'
      html = card.format.render_open
      href = "/test_another_card+*right?view=template_editor"
      text = "_left+test_another_card|content|content;"\
             "structure:test_another_card_structure"
      expect(html).to have_tag("a", with: { class: "slotter", href: href },
                                    text: text)
    end
  end
end
