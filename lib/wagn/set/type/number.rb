module Wagn::Set::Type::Number
  #include Wagn::Sets

  module Model
    def validate_content( content )
      return if content.blank? and new_card?
      self.errors.add :content, "'#{content}' is not numeric" unless valid_number?( content )
    end

    def valid_number?( string )
      valid = true
      begin
        Kernel.Float( string )
      rescue ArgumentError, TypeError
        valid = false
      end
      valid
    end
  end
end
