format :html do
  view :core do
    context_card = (tc = card.left.fetch(trait: :test_context)) &&
                    tc.item_cards.first
    card.with_context context_card do
      super()
    end
  end
end
