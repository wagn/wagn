# -*- encoding : utf-8 -*-

describe Card::Set::Type::Image do
  it "should have special editor" do
    assert_view_select render_editor('Image'), 'div[class="choose-file"]' do
      assert_select 'input[class~="file-upload slotter"]'
    end
  end

  it "should handle size argument in inclusion syntax" do
    image_card = Card.create! :name => "TestImage", :type=>"Image", :content => %{TestImage.jpg\nimage/jpeg\n12345}
    including_card = Card.new :name => 'Image1', :content => "{{TestImage | core; size:small }}"
    rendered = including_card.format._render :core
    assert_view_select rendered, 'img[src=?]', "/files/TestImage-small-#{image_card.last_content_action_id}.jpg"
  end
end
