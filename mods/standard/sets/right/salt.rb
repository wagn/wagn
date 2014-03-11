
require 'digest'

view :raw do |args|
  "Private data"
end
view :core, :raw


event :set_salt, :before=>:approve, :on=>:create do
  self.content = Digest::SHA1.hexdigest "--#{Time.now.to_s}--"
end

def ok_to_create
  is_own_account? ? true : super
end

