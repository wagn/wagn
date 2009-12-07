module Card
	class Number < Base
    def validate_content( content )
      return if content.blank? and new_record?
      errors.add :content, "'#{content}' is not numeric" unless valid_number?( content )
    end
	end
end
