format :html do
  def editor
    :text_area
  end

  view :core do
    process_content CGI.escapeHTML(_render_raw)
  end
end
