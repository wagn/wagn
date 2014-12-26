# -*- encoding : utf-8 -*-

#require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(Rails.application.config.database_configuration[Rails.env])

require_dependency 'card'
require_dependency 'card/loader'

Decko.card_paths_and_config Card.paths

# TODO: can we move these to the modules that need them?
require_dependency 'card/content'
require_dependency 'card/action'
require_dependency 'card/act'
require_dependency 'card/change'
require_dependency 'card/chunk'
require_dependency 'card/reference'
require_dependency 'card/mailer'

warn "load mods next #{Card.count}"
Card::Loader.load_mods if Card.count > 0
