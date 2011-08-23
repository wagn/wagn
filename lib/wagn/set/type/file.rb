module Wagn::Set::Type::File
  include Wagn::Model::CardAttachment
  
  def attachment_model
    CardFile
  end
  
  def item_names(args={})
    [self.name]
  end
end
