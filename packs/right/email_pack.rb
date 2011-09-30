class Wagn::Renderer 
  define_view( :raw, :right=>'*email' ) {
    ext=card.left.extension 
    ext ? ext.send('email') : ''
  } 
  alias_view :raw, {:right=>'*email'}, :naked
end
