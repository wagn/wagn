module Card
  class File < Base
    card_attachment ::CardFile
    
    def item_names(args={})
      [self.name]
    end
  end
end
