# -*- encoding : utf-8 -*-
puts "wagn/Airbreak"
filename = '/etc/airbrake.key'
if File.exists? filename
  key = File.read( filename ).strip
  Airbrake.configure do |config|
    Rails.logger.info "setting up airbrake with #{key}"
    config.api_key = key
  end
end
