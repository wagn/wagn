module Card::File
  include Wagn::Card::CardAttachment

  card_attachment CardFile
  
  def item_names(args={})
    [self.name]
  end
end
