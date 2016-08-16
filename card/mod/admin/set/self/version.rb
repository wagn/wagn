# -*- encoding : utf-8 -*-
require_dependency "card/version"

view :raw do |_args|
  Card::Version.release
end

view :core, :raw
