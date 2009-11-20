module Card
	class Percentage < Base
    def valid_content?( content )
      p = content.to_f
      valid_number?( content ) and  p >= 0 and p <=1.0
    end

    def content_for_rendering
      (content.to_f * 100.0).to_s + '%'
    end 
  
	end
end
