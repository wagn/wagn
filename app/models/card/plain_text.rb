module Card
  class PlainText < Base
    def generic?
      true
    end

    #def post_render(content)
    #  "<pre>#{content}</pre>"
    #end
  end
end
