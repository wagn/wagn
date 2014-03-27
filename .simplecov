SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/tasks/'
  add_filter '/generators/'
  add_filter 'lib/wagn'

  add_group 'Card', 'lib/card'  
  add_group 'Formats', 'mods/*/formats'
  add_group 'Chunks', 'mods/*/chunks'
  add_group 'Sets', 'tmp/sets'
end
