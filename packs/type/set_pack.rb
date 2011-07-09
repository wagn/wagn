class Wagn::Renderer
  define_view(:naked , :type=>'set') do
    div( :class=>'instruction' ) do
      Wagn::Pattern.label card.name
    end +
    '<br />' + #YUCK!

    content_tag(:h2, 'Settings') + # ENGLISH
    subrenderer(Card.new(
      :type=>'Search',
      :skip_defaults=>true,
      :content=>%{{"prepend":"#{card.name}", "type":"Setting", "sort":"name", "limit":"100"}} 
    )).render(:content) +
    '<br />' + #YUCK!

    content_tag(:h2, 'Cards in Set') +  # ENGLISH
    begin
      s2 = subrenderer(Card.fetch_or_new("#{card.name}+by update"))
      s2.item_view = :link
      s2.render(:content)
    end
  end


  define_view(:editor, :type=>'set') do 
    'Cannot currently edit Sets' #ENGLISH
  end


  alias_view(:closed_content , {:type=>:search}, {:type=>:set})
end
