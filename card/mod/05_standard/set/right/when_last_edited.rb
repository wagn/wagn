view :raw do |_args|
  card.left.new_card? ? '' : I18n.localize(card.left.updated_at, 
                                           format: :card_dayofwk_min_tz)
  #.strftime('%A, %B %d, %Y %I:%M %p %Z')
end

view :core, :raw
