class Wagn::Renderer::Text
  define_view :show do |args|
    self.render(params[:view] || :core)
  end
  
  define_view :core do |args|
    HTMLEntities.new.decode strip_tags(process_content(_render_raw))
  end
end
