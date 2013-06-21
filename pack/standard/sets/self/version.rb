# -*- encoding : utf-8 -*-

view :raw do |args|
  Wagn::Version.release
end

view :core, :raw

