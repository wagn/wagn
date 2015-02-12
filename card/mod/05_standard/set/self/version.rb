# -*- encoding : utf-8 -*-
require 'wagn/version'

view :raw do |args|
  Wagn::Version.release
end

view :core, :raw

