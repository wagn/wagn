module Card
	class Percentage < Base
	  set_editor_type "PlainText"

    set_description %{
      Enter a percentage in decimal format. (should be less than 1)
    }

    def valid_content?( content )
      p = content.to_f
      valid_number?( content ) and  p >= 0 and p <=1.0
    end

    def content_for_rendering
      (content.to_f * 100.0).to_s + '%'
    end 
  
	end
end
