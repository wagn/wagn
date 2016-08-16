include_set Type::Css

format do
  view :core do |_args|
    compile_scss(process_content _render_raw)
  end

  def compile_scss scss, style=:expanded
    Sass.compile scss, style: style
  rescue Sass::SyntaxError => e
    raise Card::Error, "Sass::SyntaxError (#{card.name}:#{e.sass_line}): " \
                       "#{e.message}"
  end
end
