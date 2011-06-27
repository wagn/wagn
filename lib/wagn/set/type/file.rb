module Wagn::Set::Type::File
  def after_include
    self.class.card_attachment CardFile
  end
  
  def item_names(args={})
    [self.name]
  end
end
