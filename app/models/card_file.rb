class CardFile < ActiveRecord::Base
  has_attachment :storage => :file_system
  
  validates_as_attachment
end
