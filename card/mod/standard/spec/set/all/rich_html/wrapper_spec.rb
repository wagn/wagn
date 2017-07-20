# -*- encoding : utf-8 -*-

describe Card::Set::All::RichHtml::Wrapper do
  context "full wrapping" do
    before do
      @ocslot = Card["A"].format
    end

    it "has the appropriate attributes on open" do
      assert_view_select(
        @ocslot.render(:open),
        'div[class="card-slot open-view ALL TYPE-basic SELF-a"]'
      ) do
        assert_select 'div[class="d0-card-frame card"]' do
          assert_select 'div[class="d0-card-header card-header"]' do
            assert_select 'div[class="d0-card-header-title card-title"]'
          end
          assert_select 'div[class~="d0-card-body"]'
        end
      end
    end

    it "has the appropriate attributes on closed" do
      v = @ocslot.render :closed
      assert_view_select(
        v, 'div[class="card-slot closed-view ALL TYPE-basic SELF-a"]'
      ) do
        assert_select 'div[class="d0-card-frame card"]' do
          assert_select 'div[class="d0-card-header card-header"]' do
            assert_select 'div[class="d0-card-header-title card-title"]'
          end
          assert_select 'div[class~="d0-card-body d0-card-content"]'
          assert_select 'div[class~="closed-content"]'
        end
      end
    end
  end
end
