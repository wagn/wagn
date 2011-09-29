class Wagn::Renderer 
  define_view( :naked, :right=>'*email' ) {
    ext=card.left.extension and ext.send('email') 
  } 
  alias_view :naked, {:right=>'*email'}, :raw
end
