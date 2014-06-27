include Machine
include MachineInput

store_machine_output :filetype => "css"

machine_input do 
  compress_css format(:format => :css)._render_core
end

def compress_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue =>e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end 

format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    # FIXME: scan must happen before process for inclusion interactions to work, but this will likely cause
    # problems with including other css?
    process_content ::CodeRay.scan( _render_raw, :css ).div, :size=>:icon
  end
  
end
