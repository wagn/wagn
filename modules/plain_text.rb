class Renderer
  # CGI.escapeHTML(_render_core).gsub(/\n/,'<br/>')
  view(:content, :type=>'plain_text') do _render_core.gsub(/\n/, '<br/>') end
  view(:editor, :type=>'plain_text') do form.text_area :content, :rows=>3 end
  view_alias( :editor, {:type=>'plain_text'},
    {:type=>:search}, {:type=>:set}, {:type=>:script} )

  view(:editor, :type=>'phrase') do form.text_field :content, :class=>'phrasebox' end

  view(:editor, :type=>'html') do form.text_area :content, :rows=>30 end
  view(:line, :type=>'html') do end # blank on purpos
end
