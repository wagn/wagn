require 'rails/all'

if Rails.env.development?
  begin
    require 'wagn/dev'
  rescue
    Rails.logger.info "WARNING: the gem wagn-dev is strongly recommended when running wagn in development mode!"
  end
end

require 'recaptcha'
require 'airbrake'

require 'smart_name'
require 'htmlentities'
require 'uuid'
require 'RMagick'
require 'paperclip'

# require 'xmlscan'
# require 'rubyzip'
require 'coderay'
require 'sass'

require 'wagn/application'
