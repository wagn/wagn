# -*- encoding : utf-8 -*-

view :raw do |args|
  Time.now.strftime '%A, %B %d, %Y %I:%M %p %Z'
end

view :core, :raw
