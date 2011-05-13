class TextRenderer
  define_view :show do
    self.render(params[:view] || :naked)
  end
  
  define_view :naked do
    HTMLEntities.new.decode strip_tags(process_content(_render_raw))
  end
end