include MachineInput

machine_input do
  variables = Card.fetch "#{name}+variables"
  style     = Card.fetch "#{name}+style"
  theme = %{    
    #{variables.format._render_raw if variables}
    $icon-font-path: "/assets/fonts/";
    @import "#{Cardio.gem_root}/mod/06_bootstrap/lib/stylesheets/bootstrap";
    #{style.format._render_raw if style}
  }
  compress_css theme
end


def compress_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue => e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end
