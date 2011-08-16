class Wagn::Renderer 
  define_view( :naked, :right=>'*content' ) { self._render_raw } 
  alias_view :naked, {:right=>'*content'}, {:right=>'*default'}
end