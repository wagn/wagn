ENV['RAILS_ENV'] = "cucumber"

require 'email_spec' # add this line if you use spork
require 'email_spec/cucumber'

#Capybara.default_driver = :selenium  #runs all tests in js

Before do
  Wagn::Cache.reset_for_tests
end