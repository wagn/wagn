module Card::File
  include Wagn::Cardlib::CardAttachment
  extend Wagn::Cardlib::CardAttachment::ActMethods

  card_attachment ::CardFile
  
  def item_names(args={})
    [self.name]
  end
end
