module Wagn::Model::Type::File
  include Wagn::Model::CardAttachment

  card_attachment CardFile
  
  def item_names(args={})
    [self.name]
  end
end
