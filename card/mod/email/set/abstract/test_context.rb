format :html do
  view :core do
    return super() if voo.hide? :test_context
    card.with_context test_context_card do
      super()
    end
  end

  def test_context_card
    (tc = card.left.fetch(trait: :test_context)) && tc.item_cards.first
  end
end

format :email_html do
  view :core do
    voo.hide! :test_context
    super()
  end
end

format :email_text do
  view :core do
    voo.hide! :test_context
    super()
  end
end
