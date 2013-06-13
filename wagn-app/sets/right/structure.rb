view :core do |args|
  with_inclusion_mode :template do
    self._final_core args
  end
end


view :closed_content do |args|
  "#{_render_type} : #{_render_raw}"
end

