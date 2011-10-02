class Wagn::Renderer 
  define_view( :raw, :right=>'*email' ) do |args|
    ext=card.left.extension 
    ext ? ext.send('email') : ''
  end 
  alias_view :raw, {:right=>'*email'}, :naked
end
