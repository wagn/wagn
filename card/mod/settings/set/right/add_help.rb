format :html do
  view :core do
    with_nest_mode :template do
      super()
    end
  end

  view :closed_content do
    "#{_render_type} : #{_render_raw}"
  end
end
