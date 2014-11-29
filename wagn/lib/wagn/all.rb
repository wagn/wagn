#warn "in wagn/all #{self.class.const_get(:Card)}"
warn "wagn/all :Constants: #{Card.class}" if Module.constants.include? :Card
require 'card'
warn 'card loaded'

require 'wagn/application'
