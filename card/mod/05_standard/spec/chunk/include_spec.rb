# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::Include, "Inclusion" do
  context "syntax parsing" do
    before do
      @class = Card::Content::Chunk::Include
    end

    let :instance do
      @class.new(@class.full_match(@chunk), nil)
    end
    let(:options) { instance.options }
    let(:name) { instance.name }
    it "ignores invisible comments" do
      expect(render_content("{{## now you see nothing}}")).to eq("")
    end

    it "handles visible comments" do
      expect(render_content("{{# now you see me}}"))
        .to eq("<!-- # now you see me -->")
      expect(render_content("{{# -->}}")).to eq("<!-- # --&gt; -->")
    end

    it "handles empty nests" do
      @chunk = "{{ }}"
      expect(name).to eq("")
      expect(options[:inc_syntax]).to eq(" ")
    end

    it "handles empty nests with pipe" do
      @chunk = "{{|}}"
      expect(name).to eq("")
      expect(options[:inc_syntax]).to eq("|")
    end

    it "handles no pipes" do
      @chunk = "{{toy}}"
      expect(name).to eq("toy")
      expect(options[:inc_name]).to eq("toy")
      expect(options.key?(:view)).to eq(false)
    end

    it "strips the name" do
      @chunk = "{{ toy }}"
      expect(name).to eq("toy")
    end

    it "strips html tags" do
      @chunk = "{{ <span>toy</span> }}"
      expect(name).to eq("toy")
    end

    it "strips html tags with pipe" do
      @chunk = "{{ <span>toy|open</span> }}"
      expect(name).to eq("toy")
      expect(options[:view]).to eq("open")
    end

    it "handles single pipe" do
      @chunk = "{{toy|view:link;hide:me}}"
      expect(options[:inc_name]).to eq("toy")
      expect(options[:view]).to eq("link")
      expect(options[:hide]).to eq("me")
      expect(options.key?(:items)).to eq(false)
    end

    it "handles multiple pipes" do
      @chunk = "{{box|open|closed}}"
      expect(options[:inc_name]).to eq("box")
      expect(options[:view]).to eq("open")
      expect(options[:items][:view]).to eq("closed")
      expect(options[:items].key?(:items)).to eq(false)
    end

    it "handles multiple pipes with blank lists" do
      @chunk = "{{box||closed}}"
      expect(options[:inc_name]).to eq("box")
      expect(options[:view]).to eq(nil)
      expect(options[:items][:view]).to eq("closed")
    end

    it "treats :item as view of next level" do
      @chunk = "{{toy|link;item:name}}"
      expect(options[:inc_name]).to eq("toy")
      expect(options[:view]).to eq("link")
      expect(options[:items][:view]).to eq("name")
    end

    it "#each_option should work" do
      @chunk = "{{}}"
      expect { |b| instance.send(:each_option, "", &b) }.not_to yield_control
      expect { |b| instance.send(:each_option, nil, &b) }.not_to yield_control
      expect { |b| instance.send(:each_option, "a:b;c:4", &b) }
        .to yield_successive_args(%w(a b), %w(c 4))
      expect { |b| instance.send(:each_option, "d:b;e:4; ", &b) }
        .to yield_successive_args(%w(d b), %w(e 4))
    end
  end

  context "rendering" do
    it "handles absolute names" do
      create! "Alpha", "Pooey"
      beta = create! "Beta", "{{Alpha}}"
      result = beta.format.render_core
      assert_view_select result, 'div[class~="card-content"]', "Pooey"
    end

    it "handles simple relative names" do
      alpha = create! "Alpha", "{{#{Card::Name.joint}Beta}}"
      create! "Beta"
      create! "#{alpha.name}#{Card::Name.joint}Beta", "Woot"
      assert_view_select alpha.format.render_core, "div[class~=card-content]",
                         "Woot"
    end

    it "handles complex relative names" do
      bob_city = create! "bob+city", "Sparta"
      Card::Auth.as_bot do
        create! "address+*right+*structure", "{{_left+city}}"
      end
      bob_address = create! "bob+address"

      r = bob_address.reload.format.render_core
      assert_view_select r, "div[class~=card-content]", "Sparta"
      expect(Card.fetch("bob+address").includees.map(&:name))
        .to eq([bob_city.name])
    end

    it "handles nesting" do
      alpha = create! "Alpha", "{{Beta}}"
      create! "Beta", "{{Delta}}"
      create! "Delta", "Booya"
      r = alpha.format.render_core
      assert_view_select r, "div[class~=card-content]"
      expect(r).to match(/Booya/)
    end

    it "handles options when nesting" do
      Card.create! type: "Pointer", name: "Livable", content: "[[Earth]]"
      create! "Earth"

      expect(render_content("{{Livable|core;item:link}}"))
        .to eq(render_content("{{Livable|core|link}}"))
      expect(render_content("{{Livable|core;item:name}}"))
        .to eq(render_content("{{Livable|core|name}}"))
    end

    it "prevents recursion" do
      create! "Oak", "{{Quentin}}"
      create! "Quentin", "{{Admin}}"
      adm = Card["Quentin"]
      adm.update_attributes content: "{{Oak}}"
      result = adm.format.render_core
      expect(result).to match("too deep")
    end

    it "handles missing cards" do
      @a = create! "boo", "hey {{+there}}"
      r = @a.format.render_core
      assert_view_select(
        r, 'div[data-card-name="boo+there"][class~="missing-view"]'
      )
    end

    it "handles structured cards" do
      create!("age")
      Card["*template"]
      specialtype = Card.create type_code: "Cardtype", name: "SpecialType"
      specialtype_template = specialtype.fetch(trait: :type, new: {})
                                        .fetch(trait: :structure, new: {})
      specialtype_template.content = "{{#{Card::Name.joint}age}}"
      Card::Auth.as_bot { specialtype_template.save! }
      assert_equal "{{#{Card::Name.joint}age}}",
                   specialtype_template.format.render_raw

      wooga = Card.create! name: "Wooga", type: "SpecialType"
      wooga_age = create! "#{wooga.name}#{Card::Name.joint}age", "39"
      expect(wooga_age.format.render_core).to eq("39")
      expect(wooga_age.includers.map(&:name)).to eq(["Wooga"])
    end

    it "handles shading" do
      create! "Alpha", "Pooey"
      create! "Beta", "{{Alpha|shade:off}}"
      r = create!("Bee", "{{Alpha|shade:off}}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select "div[class~=card-content]", "Pooey"
      end
      r = create!("Cee", "{{Alpha| shade: off }}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select "div[class~=card-content]", "Pooey"
      end
      r = create!("Dee", "{{Alpha| shade:off }}").format.render_core
      assert_view_select r, 'div[style~="shade:off;"]' do
        assert_select 'div[class~="card-content"]', "Pooey"
      end
      r = create!("Eee", "{{Alpha| shade:on }}").format.render_core
      assert_view_select r, 'div[style~="shade:on;"]' do
        assert_select 'div[class~="card-content"]', "Pooey"
      end
    end
  end
end
