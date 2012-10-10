class Wagn::Renderer 
  define_view  :core, :right=>'content'  do |args|
    self._render_raw 
  end
  alias_view :core, {:right=>'content'}, {:right=>'default'}
end