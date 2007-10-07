module Card
	class Image < Base
    def content_for_rendering
      src = "/image/#{content}?#{rand}"
      %{<a href="#{src}"><img title="#{name}" src="#{src}" /></a>}
    end
    
	end
end
