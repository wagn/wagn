describe Card::Set::All::Bootstrap::Layout do
  describe "layout dsl" do
    subject { Card["A"].format(:html) }
    it "creates correct layout with column array" do
      layout = subject.layout container: true, fluid: true do
        subject.row 6, 4, 2, class: "six-times-six" do
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
        subject.row 8, 4, class: "six-times-six" do
          subject.column "first column"
          subject.column "second column", class: "extra-class"
        end
      end
      assert_view_select layout, 'div[class="six-times-six row"]' do
        assert_select 'div[class="col-md-8"]', text: "first column"
        assert_select 'div[class="extra-class col-md-4"]', text: "second column"
      end
    end
  end
end
