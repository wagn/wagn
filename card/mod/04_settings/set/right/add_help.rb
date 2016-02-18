format :html do
  view :core do |args|
    with_nest_mode :template do
      super args
    end
  end

  view :closed_content do |_args|
    "#{_render_type} : #{_render_raw}"
  end
end
