# -*- encoding : utf-8 -*-

describe Card::Set::All::History do
  context "history view" do
    it 'should have a frame' do
      history = render_card :history, :name=>"A"
      assert_view_select history, 'div[class~="card-frame"]'
    end
  end
end
