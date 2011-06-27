module Wagn::Model::Type::File
  def after_initialize
    self.class.card_attachment CardFile
  end
  
  def item_names(args={})
    [self.name]
  end
end
