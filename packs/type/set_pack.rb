class Renderer
  define_view(:naked , :type=>'set') do
    %{<div class="instruction">#{
      Wagn::Pattern.label(card.name)}
</div>
<br />

<h2>Settings</h2>#{ # #ENGLISH
      subrenderer(Card::Search.new(:name=>UUID.new.generate, 
        :content=>%{{"prepend":"#{card.name}", "type":"Setting", "sort":"name", "limit":"100"}} # {{, "left_plus":{"right":"*type"}}}
        )).render :content}
<br />
<h2>Cards in Set</h2> #{ # #ENGLISH
      subrenderer(Card.fetch_or_new("#{card.name}+by update")).render :content }
}
  end

  define_view(:editor, :type=>'set') do 
    'Cannot currently edit Sets' #ENGLISH
  end

  view_alias(:closed_content , {:type=>:search}, {:type=>:set})
end
