module Card
	class File < Base
	  set_editor_type "Upload"
    set_description "Click to upload files from your computer."

    def content_for_rendering
      %{<a href="/file/#{content}">#{content}</a>}
    end
	end
end
