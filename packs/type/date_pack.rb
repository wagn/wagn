class Wagn::Renderer
  
  define_view(:editor, :type=>'date') do |args|
    date_id = "FIXME+date"
    link_text = card.content.blank? ? (t=Time.now(); [t.year , t.mon, t.day].join('-')) : card.content
    
    div { link_to_function( 
      link_text, "scwShow($('#{date_id}'), scwID('#{date_id}'));", :id=>date_id, :class=>'date-editor-link' )
    } +
    form.hidden_field( :content, :class=>'card-content' ) 
  end

end
