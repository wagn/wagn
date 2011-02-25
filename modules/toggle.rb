class Renderer
  view(:content, :type=>'toggle') do
    case card.content.to_i
      when 1; 'yes'
      when 0; 'no'
      else  ; '?'
      end
  end

  view(:editor, :type=>'toggle') do form.check_box(:content) end
  view_alias(:content, {:type=>'toggle'}, :line)
end
