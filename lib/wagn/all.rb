require 'rails/all'

require 'htmlentities'
require 'recaptcha'
require 'airbrake'
require 'RMagick'
require 'paperclip'
require 'coderay'
require 'haml'
#require 'scheduler_daemon'

if Rails.env == 'test'
  require 'pry'
end

require 'wagn/application'

