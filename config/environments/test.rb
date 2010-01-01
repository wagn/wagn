# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.log_level = :debug

config.gem "rspec-rails", :version => "~>1.2.6", :lib => false
config.gem "webrat", :version => "~>0.4.4", :lib => false
config.gem "cucumber", :version => "~>0.3.9", :lib => false
config.gem 'timecop'
config.gem 'spork'
config.gem 'nokogiri'
config.gem 'assert2'

# FIXME: these should be in the list here, but at the moment including them busts actually running the tests.
# config.gem 'rspec'        
# config.gem 'rspec-rails'
