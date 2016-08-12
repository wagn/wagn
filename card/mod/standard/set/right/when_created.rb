view :raw do |_args|
  # .strftime('%A, %B %d, %Y %I:%M %p %Z')
  card.left.new_card? ? "" : I18n.localize(card.left.created_at,
                                           format: :card_dayofwk_min_tz)
end

view :core, :raw
