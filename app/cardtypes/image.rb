module Card
	class Image < Base 
	  # hold image data passed from controller here until we send to to CardImage model
	  attr_accessor :card_image_id
	  
	  after_save :update_image_attachment
 
    def update_image_attachment
      if card_image_id
        CardImage.find( card_image_id ).update_attribute :revision_id, current_revision_id
      end
    end

    def card_image
      CardImage.find_by_revision_id( current_revision_id )
    end
      
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
