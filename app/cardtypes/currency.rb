module Card
	class Currency < Base
	  set_editor_type  "PlainText" 
    set_description "Enter a dollar amount"
  
    def valid_content?( content )
      valid_number?( content )
    end

    def content_for_rendering
      ('$' + sprintf("%.2f", content.to_f)).gsub(/^\$-/,'-$')
    end
	end
end
