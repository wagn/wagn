# -*- encoding : utf-8 -*-

describe Card::HtmlFormat do
  describe "views" do
    it "content" do
      result = render_card(:content, name: "A+B")
      assert_view_select(
        result,
        'div[class="card-slot content-view card-content ALL ALL_PLUS ' \
        'TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b"]'
      )
    end

    it "nests in multi edit" do
      c = Card.new name: "ABook", type: "Book"
      rendered = c.format.render(:edit)

      assert_view_select rendered, "fieldset" do
        assert_select 'div[class~="prosemirror-editor"]' do
          assert_select "input[name=?]", "card[subcards][+illustrator][content]"
        end
      end
    end

    it "titled" do
      result = render_card :titled, name: "A+B"
      assert_view_select result, 'div[class~="titled-view"]' do
        assert_select 'div[class~="card-header"]' do
          assert_select 'span[class~="card-title"]'
        end
        assert_select 'div[class~="card-body card-content"]', "AlphaBeta"
      end
    end

    context "Cards with special views" do
    end

    context "Simple page with Default Layout" do
      before do
        Card::Auth.as_bot do
          card = Card["A+B"]
          @simple_page = card.format.render(:layout)
          # warn "render sp: #{card.inspect} :: #{@simple_page}"
        end
      end

      it "renders top menu" do
        assert_view_select @simple_page, "header" do
          assert_select 'a[class="internal-link"][href="/"]', "Home"
          assert_select 'a[class="internal-link"][href="/:recent"]', "Recent"
          assert_select 'form.navbox-form[action="/:search"]' do
            assert_select 'input[name="_keyword"]'
          end
        end
      end

      it "renders card header" do
        # lots of duplication here...
        assert_view_select @simple_page,
                           'div[class="card-header panel-heading"]' do
          assert_select 'div[class="card-header-title panel-title"]'
        end
      end

      it "renders card content" do
        assert_view_select(
          @simple_page,
          'div[class="card-body panel-body card-content ALL ALL_PLUS ' \
          'TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b"]',
          "AlphaBeta"
        )
      end

      it "renders card credit" do
        assert_view_select @simple_page, 'div[class~="SELF-Xcredit"]' do
          assert_select "img"
          assert_select "a", "Wagn v#{Card::Version.release}"
        end
      end
    end

    context "layout" do
      before do
        Card::Auth.as_bot do
          @layout_card = Card.create name: "tmp layout", type: "Layout"
          # warn "layout #{@layout_card.inspect}"
        end
        c = Card["*all+*layout"]
        c.content = "[[tmp layout]]"
        @main_card = Card.fetch("Joe User")
        Card::Env[:main_name] = @main_card.name

        # warn "lay #{@layout_card.inspect}, #{@main_card.inspect}"
      end

      #      it "should default to core view when in layout mode" do
      #        @layout_card.content = "Hi {{A}}"
      #        Card::Auth.as_bot { @layout_card.save }
      #
      #        expect(@main_card.format.render(:layout)).to match('Hi Alpha')
      #      end

      #      it "should default to open view for main card" do
      #        @layout_card.content='Open up {{_main}}'
      #        Card::Auth.as_bot { @layout_card.save }
      #
      #        result = @main_card.format.render_layout
      #        expect(result).to match(/Open up/)
      #        expect(result).to match(/card-header/)
      #        expect(result).to match(/Joe User/)
      #      end

      it "renders custom view of main" do
        @layout_card.content = "Hey {{_main|name}}"
        Card::Auth.as_bot { @layout_card.save }

        result = @main_card.format.render_layout
        expect(result).to match(/Hey.*div.*Joe User/)
        expect(result).not_to match(/card-header/)
      end

      it "shouldn't recurse" do
        @layout_card.content = "Mainly {{_main|core}}"
        Card::Auth.as_bot { @layout_card.save }

        expect(@layout_card.format.render(:layout)).to eq(
          "Mainly <div id=\"main\"><div class=\"CodeRay\">\n  " \
          "<div class=\"code\"><pre>Mainly {{_main|core}}</pre></div>\n" \
          "</div>\n</div>\n" \
          '<div class="modal fade" role="dialog" id="modal-main-slot">' \
          '<div class="modal-dialog"><div class="modal-content">' \
          "</div></div></div>"
        )
        # probably better to check that it matches "Mainly" exactly twice.
      end

      it "handles nested _main references" do
        Card::Auth.as_bot do
          @layout_card.content = "{{outer space|core}}"
          @layout_card.save!
          Card.create name: "outer space", content: "{{_main|name}}"
        end

        expect(@layout_card.format.render(:layout)).to eq(
          "Joe User\n" \
          '<div class="modal fade" role="dialog" id="modal-main-slot">' \
          '<div class="modal-dialog"><div class="modal-content">' \
          "</div></div></div>"
        )
      end
    end
  end
end
