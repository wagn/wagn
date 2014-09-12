# -*- encoding : utf-8 -*-
filename = File.join Wagn.root, 'config/airbrake.key'
if File.exists? filename
  key = File.read( filename ).strip
  Airbrake.configure do |config|
    Rails.logger.info "setting up airbrake with #{key}"
    config.api_key = key
  end
end
