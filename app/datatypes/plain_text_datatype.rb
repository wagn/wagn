class PlainTextDatatype < Datatype::Base
  register "PlainText"
  editor_type "PlainText"
  description ''

  def post_render(content)
    "<pre>#{content}</pre>"
  end
  
end
