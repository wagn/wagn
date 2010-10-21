class Object
  def else what
    self
  end

  def if_card cardname
    if card = CachedCard.get_real( cardname )
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

