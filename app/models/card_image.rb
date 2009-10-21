class CardImage < ActiveRecord::Base
  belongs_to :revisions
  attr_accessor :attachment_uuid
  
  has_attachment :content_type => :image, 
                 :storage => System.attachment_storage,  
                 :size => (1..5.megabyte),   
                 :thumbnails => {
                   :icon => '16x75',
                   :small => '75x75',
                   :medium => '200x200>',
                   :large  => '500x500>'
                 } 
                 
  validates_as_attachment                 

  def preview
    %{<img width="#{width}" height="#{height}" src=\"#{public_filename(:medium)}\" />}
	end

  def bucket_name
    (System.multihost ? "#{System.wagn_name}." : "") + s3_config[:bucket_name]
  end

end
