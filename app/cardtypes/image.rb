module Card
	class Image < Base
    set_editor_type "Upload"
    set_description "Click to upload images from your computer."

    def content_for_rendering
      src = "/image/#{content}?#{rand}"
      %{<a href="#{src}"><img src="#{src}" /></a>}
    end
    
	end
end
