
view :raw do |_args|
  # '%A, %B %d, %Y %I:%M %p %Z'
  I18n.localize(Time.now, format: :card_dayofwk_min_tz)
end

view :core, :raw
