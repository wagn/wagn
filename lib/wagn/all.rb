require 'rails/all'

if Rails.env.development?
  if $LOAD_PATH.find { |path| File.exists? "#{path}/wagn/dev.rb" } 
    require 'wagn/dev'
  else
    puts "WARNING: the gem wagn-dev is strongly recommended when running wagn in development mode but is not found"
  end
end

require 'recaptcha'
require 'airbrake'

require 'smart_name'
require 'htmlentities'
require 'uuid'
require 'RMagick'
require 'paperclip'

require 'coderay'
#require 'sass'

require 'wagn/application'
