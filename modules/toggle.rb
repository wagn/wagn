class Renderer
  view(:naked, :type=>'toggle') do
    case card.raw_content.to_i
      when 1; 'yes'
      when 0; 'no'
      else  ; '?'
      end
  end

  view(:editor, :type=>'toggle') do form.check_box(:content) end
  #view_alias(:content, {:type=>'toggle'}, :line)
end
