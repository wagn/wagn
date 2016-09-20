describe Card::Set::All::Bootstrap::Layout do
  describe "layout dsl" do
    subject { Card["A"].format(:html) }
    it "creates correct layout with column array" do
      layout = subject.layout container: true, fluid: true do
        row 6, 4, 2, class: "six-times-six" do
          ["first column", "second column", "third column"]
        end
      end
      assert_view_select layout, 'div[class="container-fluid"]' do
        assert_select 'div[class="six-times-six row"]' do
          assert_select 'div[class="col-md-6"]', text: "first column"
          assert_select 'div[class="col-md-4"]', text: "second column"
          assert_select 'div[class="col-md-2"]', text: "third column"
        end
      end
    end

    it "creates correct layout with column calls" do
      layout = subject.layout do
        row 8, 4, class: "six-times-six" do
          column "first column"
          column "second column", class: "extra-class"
        end
      end
      assert_view_select layout, 'div[class="six-times-six row"]' do
        assert_select 'div[class="col-md-8"]', text: "first column"
        assert_select 'div[class="extra-class col-md-4"]', text: "second column"
      end
    end

    it "handles layout sequence" do
      format = Card["A"].format :html
      def format.generate_layout
        layout do
          row 8, 4 do
            column "first column"
            column "second column"
          end
        end

        layout do
          row 12, class: "six-times-six" do
            column "new column"
          end
        end
      end
      lay = format.generate_layout
      assert_view_select lay, 'div[class="six-times-six row"]' do
        assert_select 'div[class="col-md-8"]', false
        assert_select 'div[class="col-md-12"]', text: "new column"
      end
    end

    it "handles |nested layouts" do
      format = Card["A"].format :html
      def format.generate_layout
        layout do
          row 8, 4 do
            column(layout { row 12, ["first nested column"] } )
            column do
              layout { row 12, ["second nested column"] }
            end
          end
        end
      end
      lay = format.generate_layout
      assert_view_select lay, 'div[class="row"]' do
        assert_select 'div[class="col-md-8"]' do
          assert_select 'div[class="row"]' do
            assert_select 'div[class="col-md-12"]', text: "first nested column"
          end
        end
        assert_select 'div[class="col-md-4"]' do
          assert_select 'div[class="row"]' do
            assert_select 'div[class="col-md-12"]', text: "second nested column"
          end
        end
      end
    end
  end
end
