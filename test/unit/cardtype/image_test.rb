require File.expand_path('../../test_helper', File.dirname(__FILE__))
class Wagn::Set::Type::ImageTest < ActiveSupport::TestCase     
  #require 'action_controller'


  def setup
    super
    setup_default_user
  end

  def test_image_creation
    path = "#{Rails.root}/test/fixtures/mao2.jpg"
    mimetype = "image/jpeg"
    
    card_image = CardImage.create :uploaded_data => fixture_file_upload(path, mimetype) 
  
    @c=Card.create( :name => "Bananamaster", :typecode=>'Image', :attachment_id=>card_image.id )
    @c.class.include?(Wagn::Set::Type::Image)
  end

end
