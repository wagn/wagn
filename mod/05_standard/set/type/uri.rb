format do
  include Phrase::Format

  view :core do |args|
    build_link _render_raw(args), render_title(args) || card.name
  end

  view :uri do |args|
    build_link _render_raw(args)
  end
end
