describe Card::Set::All::RichHtml::Wrapper do  
  context "full wrapping" do
    before do
      @ocslot = Card['A'].format
    end

    it "should have the appropriate attributes on open" do
      assert_view_select @ocslot.render(:open), 'div[class="card-slot open-view card-frame ALL TYPE-basic SELF-a"]' do
        assert_select 'h1[class="card-header"]' do
          assert_select 'span[class="card-title"]'
        end
        assert_select 'div[class~="card-body"]'
      end
    end

    it "should have the appropriate attributes on closed" do
      v = @ocslot.render(:closed)
      assert_view_select v, 'div[class="card-slot closed-view card-frame ALL TYPE-basic SELF-a"]' do
        assert_select 'h1[class="card-header"]' do
          assert_select 'span[class="card-title"]'
        end
        assert_select 'div[class~="closed-content card-content"]'
      end
    end
  end
end