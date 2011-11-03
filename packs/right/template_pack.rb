class Wagn::Renderer 
  define_view( :core, :right=>'*content' ) { |args| self._render_raw } 
  alias_view :core, {:right=>'*content'}, {:right=>'*default'}
end