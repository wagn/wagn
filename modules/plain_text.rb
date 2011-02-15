class Renderer
  # CGI.escapeHTML(_render_core).gsub(/\n/,'<br/>')
  view(:content, :type=>'plain_text') do _render_core.gsub(/\n/, '<br/>') end
  view(:editor, :type=>'plain_text') do form.text_area :content, :rows=>3 end
end
