format do
  include Phrase::Format

  view :core do |args|
    web_link _render_raw(args), text: render_title(args)
  end

  view :url_link do |args|
    web_link _render_raw(args)
  end
end
