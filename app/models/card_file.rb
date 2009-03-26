class CardFile < ActiveRecord::Base
  belongs_to :revisions         
  attr_accessor :attachment_uuid
  
  has_attachment :storage => :s3
  validates_as_attachment              
  
  def preview
    "<a href=\"#{public_filename}\">#{public_filename}</a>"
	end

  def bucket_name
    System.multihost_name ? "#{System.multihost_name}_wagn" :  s3_config[:bucket_name]
  end
end
