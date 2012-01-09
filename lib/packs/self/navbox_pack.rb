class Wagn::Renderer
  define_view(:raw, :name=>'*navbox') do |args|
    %{ <form action="#{Card.path_setting '/*search'}" id="navbox-form" method="get">
      #{hidden_field_tag :view, 'content' }
      #{text_field_tag :_keyword, '', :class=>'navbox' }
     </form>}
  end
  alias_view(:raw, {:name=>'*navbox'}, :core)
end

class Wagn::Renderer::Json < Wagn::Renderer
  define_view(:complete, :name=>'*search') do |args|
    term = params['term']
    if term =~ /^\+/ && main = params['main']
      term = main+term
    end
    
    exact = Card.fetch_or_new(term)
    goto_cards = Card.search( :complete=>term, :limit=>8, :sort=>'name', :return=>'name' )
    goto_cards.unshift term if exact.virtual?
    
    JSON({ 
      :search => true, # card.ok?( :read ),
      :add    => (exact.new_card? && exact.cardname.valid? && !exact.virtual? && exact.ok?( :create )),
      :new    => (exact.typecode=='Cardtype' && 
                  Card.new(:typecode=>exact.codename).ok?(:create) && 
                  [exact.name, exact.cardname.to_url_key]
                 ),
      :goto   => goto_cards.map { |name| [name, highlight(name, term), name.to_cardname.to_url_key] }
    })    
  end
end