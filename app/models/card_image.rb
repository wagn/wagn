class CardImage < ActiveRecord::Base
  belongs_to :revisions
  attr_accessor :attachment_uuid
  
  has_attachment :content_type => :image, 
                 :storage => :s3,   
                 :size => (1..5.megabyte),   
                 :thumbnails => {
                   :icon => '16x75',
                   :small => '75x75',
                   :medium => '200x200',
                   :large  => '500x500'
                 } 
                 
  validates_as_attachment                 
    
end
