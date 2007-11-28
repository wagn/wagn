module Card
	class Image < Base
	  def src
	    "/image/#{content}?#{updated_at.to_i}"
    end
    
    def image_exists?
      File.exists?("#{RAILS_ROOT}/public/image/#{content}")
      return "#{RAILS_ROOT}/public/image/#{content}"
    end
=begin
    def content_for_rendering
      src = "/image/#{content}?#{updated_at.to_i}"
      %{<a href="#{src}"><img title="#{name}" src="#{src}" /></a>}
    end
=end
    
	end
end
