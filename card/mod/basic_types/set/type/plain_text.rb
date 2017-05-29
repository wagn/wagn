format :html do
  def editor
    :plain_text
  end

  view :core do
    process_content CGI.escapeHTML(_render_raw)
  end
end
