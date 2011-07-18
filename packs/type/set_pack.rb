class Wagn::Renderer
  define_view(:naked , :type=>'set') do
    
    setting_groups = card.setting_names_by_group
    div( :class=>'instruction' ) { label card.name } + '<br />' + #YUCK!

    content_tag(:h2, 'Settings') + # ENGLISH
    [:viewing, :editing, :creating].map do |group|
      div(:class=>"setting-group #{group}-setting-group") do
        content_tag(:h3, group.to_s.capitalize) +
         setting_groups[group].map do |setting_name| 
          rule_card = Card.fetch_or_new "#{card.name}+#{setting_name}", :skip_defaults=>true, :skip_virtual=>true
          div(:class=>'rule-item') { process_inclusion(rule_card, :view=>:closed) }
        end.join
      end
    end.join() +
    

#    subrenderer(Card.new(
#      :type=>'Search',
#      :skip_defaults=>true,
#      :content=>%{{"prepend":"#{card.name}", "type":"Setting", "sort":"name", "limit":"100"}} 
#    )).render(:content) +
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
