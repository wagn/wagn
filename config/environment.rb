# Load the rails application
require File.expand_path('../application', __FILE__)

Ddb::Userstamp.compatibility_mode = true

# Initialize the rails application
Wagn::Application.initialize!
