# Add new inflection rules using the following format 
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'grave', 'graveyard'
  inflect.irregular 'this', 'this'     
  inflect.irregular 'anonymous', 'anonymous'   
  inflect.singular(/(ss)$/i, '\1')
  inflect.plural(/(ss)$/i, '\1')
end
