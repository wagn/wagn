module Card
	class File < Base
    def content_for_rendering
      %{<a href="/file/#{content}">#{content}</a>}
    end
	end
end
