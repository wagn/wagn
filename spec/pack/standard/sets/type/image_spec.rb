# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::Type::Image do
  it "should have special editor" do
    assert_view_select render_editor('Image'), 'div[class="choose-file"]' do
      assert_select 'input[class="file-upload slotter"]'
    end
  end

  it "should handle size argument in inclusion syntax" do
    image_card = Card.create! :name => "TestImage", :type=>"Image", :content => %{TestImage.jpg\nimage/jpeg\n12345}
    including_card = Card.new :name => 'Image1', :content => "{{TestImage | core; size:small }}"
    rendered = Card::Format.new(including_card)._render :core
    assert_view_select rendered, 'img[src=?]', "/files/TestImage-small-#{image_card.current_revision_id}.jpg"
  end
end
