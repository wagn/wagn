module Wagn::Set::Default::Text
  class Wagn::Renderer::Text
    define_view :core, :format=>:text do |args|
      HTMLEntities.new.decode strip_tags( process_content( _render_raw ) )
    end
  end
end
