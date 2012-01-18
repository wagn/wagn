class Wagn::Renderer 
  define_view( :raw, :right=>'*email' ) do |args|
    ext=User.where(:card_id=>card.left.id).first 
    ext ? ext.send('email') : ''
  end 
  alias_view :raw, {:right=>'*email'}, :core
end
