class FileDatatype < Datatype::Base
  
  register "File"
  editor_type "Upload"
  description %{
    Click to upload files from your computer.
  }

  def content_for_rendering
    %{<a href="/file/#{@card.content}">#{@card.content}</a>}
  end
  
  def allow_duplicate_revisions
    true
  end
  
end
