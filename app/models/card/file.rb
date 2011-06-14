class Card::File < Card
  card_attachment ::CardFile
  
  def item_names(args={})
    [self.name]
  end
end
