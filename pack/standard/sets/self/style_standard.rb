# -*- encoding : utf-8 -*-
view :raw do |args|
  File.read "#{Rails.root}/app/assets/stylesheets/standard.scss"
end
