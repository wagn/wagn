
format :html do
  
  view :title do |args|
    vars = root.search_params[:vars]
    if vars && vars[:keyword]
       args.merge! :title=> %{Search results for: <span class="search-keyword">#{ vars[:keyword] }</span>}
    end
    super args
  end
end


format :json do

  view :complete do |args|
    term = params['_keyword']
    if term =~ /^\+/ && main = params['main']
      term = main+term
    end

    exact = Card.fetch term, :new=>{}
    goto_cards = Card.search goto_wql(term)
    goto_cards.unshift exact.name if exact.known? && !goto_cards.map{|n| n.to_name.key}.include?(exact.key) 

    {
      :search => true, # card.ok?( :read ),
      :add    => (exact.new_card? && exact.cardname.valid? && !exact.virtual? && exact.ok?( :create ) && exact.name),
      :new    => (exact.type_id==Card::CardtypeID &&
                  Card.new(:type_id=>exact.type_id).ok?(:create) &&
                  [exact.name, exact.cardname.url_key]
                 ),
      :goto   => goto_cards.map { |name| [name, highlight(name, term), name.to_name.url_key] }
    }
  
  end
  
  #hacky.  here for override
  def goto_wql(term)
   { :complete=>term, :limit=>8, :sort=>'name', :return=>'name' }
  end
  
end
