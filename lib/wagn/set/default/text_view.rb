module Wagn::Set::Default
  class Wagn::Renderer
    define_view :core, :format=>:text do |args|
      HTMLEntities.new.decode strip_tags( process_content( _render_raw ) )
    end
  end
end
