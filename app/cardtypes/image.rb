module Card
	class Image < Base 
    has_one :card_image, :foreign_key=>:card_id

	  # hold image data passed from controller here until we send to to CardImage model
	  attr_accessor :image_data                                                        
	  
	  after_create :create_image_attachment
 
    def create_image_attachment
      create_card_image( :uploaded_data => image_data )
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
