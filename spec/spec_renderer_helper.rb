class Renderer
  # declare a test builtin
  view(:raw, '*builtin+*self') do
    'Boo'
  end
end
