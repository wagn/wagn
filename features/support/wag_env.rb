# -*- encoding : utf-8 -*-
require 'email_spec' # add this line if you use spork
require 'email_spec/cucumber'
#require 'capybara-webkit'

#Capybara.javascript_driver = :webkit

Before do
  Wagn::Cache.restore
end
