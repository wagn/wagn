# -*- encoding : utf-8 -*-
view :raw do |args|
  File.read "#{Rails.root}/pack/standard/lib/stylesheets/functional.scss"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
