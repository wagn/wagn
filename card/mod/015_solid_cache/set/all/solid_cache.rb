def solid_cache?
  respond_to?(:solid_cache_card)
end

module ClassMethods
  def clear_solid_cache
    Auth.as_bot do
      Card.search(right: { codename: 'solid_cache' }).each do |card|
        card.delete!
      end
    end
  end
end