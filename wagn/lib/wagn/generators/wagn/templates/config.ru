# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
<% if options['core-dev'] -%>

if Rails.env.profile?
  use Rack::RubyProf, :path => 'tmp/profile'
end

<% end -%>
run <%= app_const %>
