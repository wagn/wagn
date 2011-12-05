class Wagn::Renderer
  define_view(:raw, :name=>'*navbox') do |args|
    form_tag '/*search', :id=>'navbox-form', :method=>'get' do
      text_field_tag :_keyword, '', :class=>'navbox'
    end
  end
  alias_view(:raw, {:name=>'*navbox'}, :core)
end

class Wagn::Renderer::Json < Wagn::Renderer
  define_view(:complete, :name=>'*search') do |args|
    term = params['term']
    exact = Card.fetch_or_new(term)
    JSON({ 
      :search => true, # card.ok?( :read ),
      :add    => (exact.new_card? && exact.ok?( :create )),
      :type   => (exact.typecode=='Cardtype' && 
                  Card.new(:typecode=>exact.codename).ok?(:create) && 
                  [exact.name, exact.cardname.to_url_key]
                 ),
      :goto   => Card.search( :complete=>term, :limit=>8, :sort=>'name', :return=>'name' ).map do |name|
          [name, highlight(name, term), name.to_cardname.to_url_key]
        end
    })
  end
end