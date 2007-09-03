module Card
	class Number < Base
	  set_editor_type "PlainText"
    def validate_content( content )
      return if content.blank? and new_record?
      errors.add :content, "is not numeric" unless valid_number?( content )
    end
	end
end
