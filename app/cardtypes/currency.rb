module Card
	class Currency < Base
    def valid_content?( content )
      valid_number?( content )
    end

    def content_for_rendering
      ('$' + sprintf("%.2f", content.to_f)).gsub(/^\$-/,'-$')
    end
	end
end
