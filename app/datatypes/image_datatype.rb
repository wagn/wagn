class ImageDatatype < Datatype::Base
  
  register "Image"
  editor_type "Upload"
  
  description %{
    Click to upload images from your computer.
  }
  
  def content_for_rendering
    src = "/image/#{@card.content}?#{rand}"
    %{<a href="#{src}"><img src="#{src}" /></a>}
  end

  def allow_duplicate_revisions
    true
  end
  
   
end
