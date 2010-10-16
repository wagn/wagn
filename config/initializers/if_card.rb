class Object
  def else what
    self
  end

  def if_card cardname
    if card = Card.fetch( cardname , :skip_virtual => true)
      yield(card)
    else
      nil
    end
  end
end

class NilClass
  def else what
    what
  end
end

