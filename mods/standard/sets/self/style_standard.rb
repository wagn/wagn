# -*- encoding : utf-8 -*-
view :raw do |args|
  File.read "#{Rails.root}/mods/standard/lib/stylesheets/standard.scss"
end

view :editor do |args|
  "Content is stored in file and can't be edited."
end
