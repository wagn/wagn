module Wagn::Set::Type::Image  
  def after_include
    self.class.card_attachment CardImage
  end
end
