view :raw do |_args|
  card.left.new_card? ? '' : card.left.updated_at.strftime('%A, %B %d, %Y %I:%M %p %Z')
end

view :core, :raw
