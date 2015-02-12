# -*- encoding : utf-8 -*-
require 'card/version'

view :raw do |args|
  Card::Version.release
end

view :core, :raw

