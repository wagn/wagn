class Renderer
  view(:editor, :type=>'html') do form.text_area :content, :rows=>30 end
  view(:line, :type=>'html') do end # blank on purpos
end
