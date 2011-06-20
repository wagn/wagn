module Card::Image
  def self.included(base)
    base.include Wagn::Card::CardAttachment
    base.card_attachment CardImage
  end
end
