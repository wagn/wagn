def followable?
  false
end

def history?
  false
end

def clean_html?
  false
end

format :html do
  view :core do |args|
    return super(args) unless card.new_card?
    _render_missing args.merge(denied_view: :core)
  end

  view :missing do |args|
    if @card.new_card? &&
       (l = @card.left) &&
       l.solid_cache?
      l.update_solid_cache
      @card = Card.fetch(card.name)
      render(args[:denied_view], args)
    else
      super(args)
    end
  end

  view :new, :missing
end
