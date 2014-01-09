# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# to test non-root in webrick, uncomment the map call and use this command:
# > env RAILS_RELATIVE_URL_ROOT='/root' rails server

# map '/root' do
  run Wagn::Application
# end