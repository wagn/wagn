
require 'digest'

view :raw do |args|
  "Private data"
end
view :core, :raw


#self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
