require File.dirname(__FILE__) + '/../../test_helper'
class Card::ImageTest < Test::Unit::TestCase       
  # required to use ActionController::TestUploadedFile 
  require 'action_controller'
  require 'action_controller/test_process.rb'
  
  common_fixtures
  
  def setup
    setup_default_user
  end
  
  def test_image_creation
    path = "#{RAILS_ROOT}/test/fixtures/mao2.jpg"
    mimetype = "image/jpeg"

    @c=Card::Image.create( :name=>'BananaMaster',
     :image_data => ActionController::TestUploadedFile.new(path, mimetype) )

    assert_instance_of Card::Image, @c
    assert_instance_of CardImage, @c.card_image
  end
  
end
