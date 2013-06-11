# -*- encoding : utf-8 -*-

view :raw  do |args|
  Wagn::Version.to_s
end

#view(:raw, {:name=>:version}, :core)