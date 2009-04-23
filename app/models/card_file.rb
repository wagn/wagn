class CardFile < ActiveRecord::Base
  belongs_to :revisions         
  attr_accessor :attachment_uuid
  
  has_attachment :storage => :s3, :size => (1..100.megabyte)
  validates_as_attachment              
  
  def preview
    "<a href=\"#{public_filename}\">#{filename}</a>"
	end

  def bucket_name
    (System.multihost ? "#{System.wagn_name}." : "") + s3_config[:bucket_name]
  end
end
