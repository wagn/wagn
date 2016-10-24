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
  view :core do
    return super() unless card.new_card?
    @denied_view = :core
    _render_missing
  end

  view :missing do
    if @card.new_card? && (l = @card.left) && l.solid_cache?
      l.update_solid_cache
      @card = Card.fetch card.name
      render @denied_view
    else
      super()
    end
  end

  view :new, :missing
end
