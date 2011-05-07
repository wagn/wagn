# Add new inflection rules using the following format 
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'grave', 'graveyard'
  inflect.irregular 'this', 'this'
  inflect.irregular 'anonymous', 'anonymous'
  inflect.irregular 's', 's'
  inflect.singular(/(ss)$/i, '\1')
  inflect.plural(/(ss)$/i, '\1')
end
