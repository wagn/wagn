class Renderer
  # declare a test builtin
  define_view(:raw, :name=>'*builtin') do
    'Boo'
  end
end
