require File.dirname(__FILE__) + '/../../test_helper'
class Wagn::Set::Type::ImageTest < ActiveSupport::TestCase       
  # required to use ActionController::TestUploadedFile 
  require 'action_controller'
  require 'action_controller/test_process.rb'
  
  
  
  def setup
    super
    setup_default_user
  end
  
  def test_image_creation
    path = "#{RAILS_ROOT}/test/fixtures/mao2.jpg"
    mimetype = "image/jpeg"
      
    card_image = CardImage.create :uploaded_data => ActionController::TestUploadedFile.new(path, mimetype) 
    @c=Card.create( :name => "Bananamaster", :typecode=>'Image', :attachment_id=>card_image.id )
    @c.class.include?(Wagn::Set::Type::Image)
  end
  
end
