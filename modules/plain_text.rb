class Renderer
  view(:naked, :type=>'plain_text') do process_content(_render_raw).gsub(/\n/, '<br/>') end
  view(:editor, :type=>'plain_text') do form.text_area :content, :rows=>3 end
  view_alias( :editor, {:type=>'plain_text'},
    {:type=>:search}, {:type=>:set}, {:type=>:script} )

  view(:editor, :type=>'phrase') do form.text_field :content, :class=>'phrasebox' end
  view(:editor, :type=>'number') do form.text_field :content end

  view(:editor, :type=>'html') do form.text_area :content, :rows=>30 end
  view(:closed_content, :type=>'html') do '' end # blank on purpos
end
