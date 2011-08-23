module Wagn::Set::Type::Image
  include Wagn::Model::CardAttachment
  
  def attachment_model
    CardImage
  end
end
