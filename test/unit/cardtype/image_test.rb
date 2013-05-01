# -*- encoding : utf-8 -*-
require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Wagn::Set::Type::ImageTest < ActiveSupport::TestCase
  #require 'action_controller'


  def setup
    super
    setup_default_user
  end

  def test_image_creation
    card=Card.create :name => "Bananamaster", :typecode=>'image',
                   :attach=>File.new("#{Rails.root}/test/fixtures/mao2.jpg")
    assert_match /^\/files\/Bananamaster-original-\d+/, card.attach.url
  end

end
