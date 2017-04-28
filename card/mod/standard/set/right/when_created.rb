view :raw do |_args|
  # .strftime('%A, %B %d, %Y %I:%M %p %Z')
  return "" if !(left = card.left) || left.new_card?
  I18n.localize(left.created_at,format: :card_dayofwk_min_tz)
end

view :core, :raw
