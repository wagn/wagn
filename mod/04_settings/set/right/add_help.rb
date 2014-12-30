format :html do
  view :core do |args|
    with_inclusion_mode :template do
      super args
    end
  end
  
  view :closed_content do |args|
    "#{_render_type} : #{_render_raw}"
  end
end
