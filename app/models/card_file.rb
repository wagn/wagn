class CardFile < ActiveRecord::Base
  belongs_to :revisions         
  attr_accessor :attachment_uuid
  
  has_attachment :storage => :s3
  validates_as_attachment              
  
  def preview
    "<a href=\"#{public_filename}\">#{public_filename}</a>"
	end
  
end
