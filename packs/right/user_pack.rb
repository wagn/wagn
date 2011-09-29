class Wagn::Renderer 
  define_view( :naked, :right=>'*email' ) {
    c = fetch(card.cardname) and e=c.extension and e.send('email')
  } 
end
