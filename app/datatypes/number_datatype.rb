class NumberDatatype < Datatype::Base
  
  register "Number"
  editor_type "PlainText"
  
  description %{
    Enter a number
  }
  
  def valid_content?( content )
    valid_number?( content )
  end
  
end
