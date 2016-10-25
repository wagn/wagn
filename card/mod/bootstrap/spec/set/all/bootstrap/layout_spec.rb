describe Card::Set::All::Bootstrap::Layout do
  describe "layout dsl" do
    subject { Card["A"].format(:html) }
    it "creates correct layout with column array" do
      layout = subject.layout container: true, fluid: true do
        row 6, 4, 2, class: "six-times-six" do
          ["c1", "c2", "c3"]
        end
      end
      assert_view_select layout, 'div[class="container-fluid"]' do
        assert_select 'div[class="row six-times-six"]' do
          assert_select 'div[class="col-md-6"]', text: "c1"
          assert_select 'div[class="col-md-4"]', text: "c2"
          assert_select 'div[class="col-md-2"]', text: "c3"
        end
      end
    end

    it "creates correct layout with column calls" do
      layout = subject.layout do
        row 8, 4, class: "six-times-six" do
          column "c1"
          column "c2", class: "extra-class"
        end
      end
      assert_view_select layout, 'div[class="row six-times-six"]' do
        assert_select 'div[class="col-md-8"]', text: "c1"
        assert_select 'div[class="col-md-4 extra-class"]',
                      text: "c2"
      end
    end

    it "handles different medium sizes" do
      layout = subject.layout do
        row md: [8, 4], xs: [6, 6], class: "six-times-six" do
          column "c1"
          column "c2", class: "extra-class"
        end
      end
      debug_assert_view_select layout, 'div[class="row six-times-six"]' do
        assert_select 'div[class="col-md-8 col-xs-6"]', text: "c1"
        assert_select 'div[class="col-md-4 col-xs-6 extra-class"]',
                      text: "c2"
      end
    end

    it "handles layout sequence" do
      # format = Card["A"].form
      def subject.generate_layout
        layout do
          row 8, 4 do
            column "c1"
            column "c2"
          end
        end

        layout do
          row 12, class: "six-times-six" do
            column "new column"
          end
        end
      end
      lay = subject.generate_layout
      # assert_view_select lay, 'div[class="row"]' do
      #   assert_select 'div[class="col-md-8"]', text: "c1"
      #   assert_select 'div[class="col-md-4"]', text: "c2"
      # end
      assert_view_select lay, 'div[class="row six-times-six"]' do
        assert_select 'div[class="col-md-12"]', text: "new column"
      end
    end

    it "handles nested layouts" do
      # format = Card["A"].format :html
      def subject.generate_layout
        layout do
          row 8, 4 do
            column do
              layout { row 12, ["c1"] }
            end
            column do
              row 12, ["c2"]
              row 6 do
                html "<span>s1</span>"
                column "c3"
              end
              row 8 do
                "some content"
              end
            end
          end
        end
      end
      lay = subject.generate_layout
      debug_assert_view_select lay, 'div[class="row"]' do
        assert_select 'div[class="col-md-8"]' do
          assert_select 'div[class="row"]' do
            assert_select 'div[class="col-md-12"]', text: "c1"
          end
        end
        assert_select 'div[class="col-md-4"]' do
          assert_select 'div[class="row"]' do
            assert_select 'div[class="col-md-12"]', text: "c2"
          end
          assert_select 'div[class="row"]' do
            assert_select 'div[class="col-md-6"]', text: "c3"
            assert_select 'span', text: "s1"
          end
          assert_select 'div[class="row"]', text: "some content"
        end
      end
    end
  end
end
