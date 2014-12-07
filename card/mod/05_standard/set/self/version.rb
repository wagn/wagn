# -*- encoding : utf-8 -*-

view :raw do |args|
  Card::Version.release
end

view :core, :raw

