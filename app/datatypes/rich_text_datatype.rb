class RichTextDatatype < Datatype::Base
  register "RichText"
  editor_type "RichText"
  description ''

  def post_render(content)
    #warn "post render: #{content}"
    content
    table_of_contents(content) 
  end
  
  def table_of_contents(content)
    toc = []  
    current_depth = 1
    content.gsub!( /<(h1)>(.*?)<\/h1>|<(h2)>(.*?)<\/h2>/i ) do
      tag, value = $~[1] ? $~[1,2] : $~[3,2]
      item = { :value => value, :uri => URI.escape(value) }
      case tag
        when 'h1'
          item[:depth] = current_depth = 1          
          toc << item
        when 'h2'
          toc << []  if current_depth == 1
          item[:depth] = current_depth = 2
          toc.last << item
      end
      %{<a name="#{item[:uri]}"></a>} + $MATCH
    end
    
    length = toc.flatten.length 
    add_toc = false
    toc_card_content = '' 
    if length > 0 
      toc_card = @card.attribute_card("*table of contents")
      toc_card_content = toc_card ? toc_card.content : ''
      if  !toc_card_content.match('off') and (toc_card_content.match('on') or length > 3)
        add_toc = true
      end
    end
    
    if add_toc
      content.replace %{ <div class="table-of-contents"> <h5>Table of Contents</h5> } +
        make_list(toc) + '</div>'+ content 
    else
     content
    end
    
  end

  
  def before_save(content)
    WikiContent.clean_html!(content)
    #warn "before save: #{content}"
    #content
  end
  
  private
  
  def make_list(items)
    list = items.collect do |i|
      Array === i ? make_list(i) : %{<li><a href="##{i[:uri]}"> #{i[:value]}</a></li>}
    end.join("\n")
    "<ol>" + list + "</ol>"
  end
  
  
end



