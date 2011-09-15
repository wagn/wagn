class Wagn::Renderer
  define_view(:naked, :type=>'setting') do |args|
    div( :class=>'instruction') do
      process_content "{{+*right+*edit help}}"
    end +

    Wagn::Pattern.subclasses.reverse.map do |set_class|
      key = set_class.key
      search_card = Card.new(
        :type =>'Search',
        :skip_defaults=>true,
        :content=>%~
          { "left":{
              "type":"Set",
              "#{set_class.trunkless? ? 'name' : 'right'}":"#{key}"
            },
            "right":"#{card.name}","sort":"name","limit":"100"
          }
        ~
      )
      next if search_card.count == 0
      content_tag(:h2, (set_class.trunkless? ? '' : '+') + key, :class=>'values-for-setting') +
      subrenderer(search_card).render(:content)
    end.compact * "\n"
  end

  define_view(:closed_content, :type=>'setting') do |args|
    div( :class=>"instruction" ) do
      process_content "{{+*right+*edit help}}"
    end
  end
end
