class Wagn::Renderer
  define_view(:core, :type=>'setting') do |args|
    div( :class=>'instruction') do
      raw process_content( "{{+*right+*edit help}}" )
    end +

    raw(
        card.patterns.reverse.map do |set_pattern|
        set_class = set_pattern.class
        search_card = Card.new(
          :type =>'Search',
          :content=>%~
            { "left":{
                "type":"Set",
                "#{set_class.trunkless? ? 'name' : 'right'}":"#{set_class.key}"
              },
              "right":"#{card.name}","sort":"name","limit":"100"
            }
          ~
        )
        next if search_card.count == 0
        content_tag( :h2, 
          raw( (set_class.trunkless? ? '' : '+') + set_class.key), 
          :class=>'values-for-setting'
        ) + 
        
        raw( subrenderer(search_card).render(:content) )
      
      end.compact * "\n"
    )
  end

  define_view(:closed_content, :type=>'setting') do |args|
    div( :class=>"instruction" ) do
      process_content "{{+*right+*edit help}}"
    end
  end
end
