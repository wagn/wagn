class Object
  def else what
    self
  end

  def if_card cardname
    (card = Card[cardname] ) ? yield(card) : nil
  end
end

class NilClass
  def else what
    what
  end
end

