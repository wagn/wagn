describe 'bootstrap builder' do
  class BuilderTest < Card::Set::All::Bootstrap::BootstrapBuilder
    add_tag_method :test_tag, "test-class" do |opts, extra_args|
      prepend { tag :prepend, "prepend-class" }
      append { tag :append, "append-class" }
      insert { tag :insert, "insert-class" }
      #wrap { |content| tag :wrap, "wrap-class" { content } }
      opts
    end
  end

  describe "tag create helper methods" do
    subject do
      fo = Card["A"].format(:html)
      tag = BuilderTest.render(fo) { test_tag }
      "<buildertest>#{tag}<buildertest>"
    end
    it 'appends work' do
      #assert_select 'prepend[class="prepend-class"]'
      assert_view_select subject, "buildertest" do
        #assert_select 'prepend[class="prepend-class]"'
        assert_select 'prepend[class="prepend-class]"'
        assert_select 'test_tag[class="test-class"]' do
          assert_select 'insert[class="insert-class]"'
        end

        assert_select 'append[class="append-class]"'
      end
    end
  end
end
