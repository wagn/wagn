def followable?
  false
end

def history?
  false
end

format :html do
  view :missing do |args|
    if @card.new_card? &&
      (l = @card.left) &&
      l.respond_to?(:update_solid_cache)
      l.update_solid_cache
      @card = Card.fetch(card.name)
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end
