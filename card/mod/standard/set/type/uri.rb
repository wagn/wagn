format do
  include Phrase::Format

  view :core do |args|
    link_to_resource _render_raw(args), render_title(args)
  end

  view :url_link do |args|
    link_to_resource _render_raw(args)
  end
end
