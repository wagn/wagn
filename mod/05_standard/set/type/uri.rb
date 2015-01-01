format do
  include Phrase::Format

  view :core do |args|
    if args[:url_link_text]
      build_link _render_raw(args)
    else
      build_link _render_raw(args), render_title(args)
    end
  end

end
