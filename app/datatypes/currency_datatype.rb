class CurrencyDatatype < Datatype::Base
  
  register "Currency"
  editor_type "PlainText"
  
  description %{
    Enter a dollar amount
  }
  
  def valid_content?( content )
    valid_number?( content )
  end
  
  def content_for_rendering
    ('$' + sprintf("%.2f", @card.content.to_f)).gsub(/^\$-/,'-$')
  end
  
end
