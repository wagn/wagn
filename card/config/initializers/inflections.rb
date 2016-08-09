# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular "grave", "graveyard"
  inflect.uncountable "this"
  #  inflect.uncountable 'plus'
  inflect.uncountable "anonymous"
  inflect.uncountable "s"
  inflect.singular(/(ss)$/i, '\1')
  inflect.plural(/(ss)$/i, '\1')
end
