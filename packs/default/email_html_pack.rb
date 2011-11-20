class Wagn::Renderer::EmailHtml
  define_view(:missing)        { |args| '' }
  define_view(:closed_missing) { |args| '' }
end
