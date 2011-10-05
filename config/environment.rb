# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Wagn::Application.initialize!

#ActionController::Dispatcher.to_prepare do
#  Wagn::Configuration.wagn_run
#end

Wagn::Configuration.wagn_run