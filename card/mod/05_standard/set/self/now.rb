
view :raw do |_args|
  Time.now.strftime '%A, %B %d, %Y %I:%M %p %Z'
end

view :core, :raw
