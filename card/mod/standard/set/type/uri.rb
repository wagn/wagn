format do
  include Phrase::Format

  view :core do
    link_to_resource _render_raw, render_title
  end

  view :url_link do
    link_to_resource _render_raw
  end
end
