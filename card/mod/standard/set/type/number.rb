
view :editor do |_args|
  text_field :content, class: "card-content"
end

event :validate_number, :validate do
  errors.add :content, "'#{content}' is not numeric" unless valid_number?(content)
end

def valid_number? string
  valid = true
  begin
    Kernel.Float(string)
  rescue ArgumentError, TypeError
    valid = false
  end
  valid
end
