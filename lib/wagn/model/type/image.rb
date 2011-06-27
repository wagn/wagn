module Wagn::Model::Type::Image
  def after_initialize
    self.class.card_attachment CardImage
  end
end
