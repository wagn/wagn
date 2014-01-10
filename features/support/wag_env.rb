# -*- encoding : utf-8 -*-
require 'email_spec' # add this line if you use spork
require 'email_spec/cucumber'

Capybara.configure do |config|
  config.match = :prefer_exact
end

Before do
  Wagn::Cache.restore
end
