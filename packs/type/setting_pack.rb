class Renderer
  define_view(:naked, :type=>'setting') do
    div( :class=>'instruction') do
      process_content "{{+*right+*edit help}}"
    end +

    Wagn::Pattern.subclasses.reverse.map do |set_class|
      key = set_class.key
      content_tag(:h2, (key=='*all' ? '*all' : "+#{key}"), :class=>'values-for-setting') +
      subrenderer(Card::Search.new(
        :name=>UUID.new.generate,
        :content=>%~
          { "left":{
              "type":"Set",
              "#{key=='*all' ? 'name' : 'right'}":"#{key}"
            },
            "right":"#{card.name}","sort":"name","limit":"100"
          }
        ~
      )).render(:content)
    end * "\n"
  end

  define_view(:closed_content, :type=>'setting') do
    div( :class=>"instruction" ) do
      process_content "{{+*right+*edit help}}"
    end
  end
end
