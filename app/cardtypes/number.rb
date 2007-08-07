module Card
	class Number < Base
	  set_editor_type "PlainText"
    def validate_content( content )
      errors.add :content, "is not numeric" unless valid_number?( content )
    end
	end
end
