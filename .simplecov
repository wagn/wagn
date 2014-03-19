SimpleCov.start do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/tasks/'
  add_filter '/generators/'
  
  add_group 'Mods', 'mods'
  add_group 'Card', 'lib/card'
  add_group 'Wagn', 'lib/wagn'
end
