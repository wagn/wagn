require 'rubygems'
require 'spork'
        
 
 
Spork.prefork do
  # Sets up the Rails environment for Cucumber
  ENV["RAILS_ENV"] ||= "cucumber"
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
 
  require 'webrat'
  
 
  Webrat.configure do |config|
    config.application_framework = :rails
    if ENV["WEBRAT_MODE"] == "selenium"
      config.application_environment = :test
      config.mode = :selenium
    else
      config.application_environment = :cucumber
      config.mode = :rails   
    end
  end
 
  require 'webrat/core/matchers'
  require 'cucumber'

  # Comment out the next line if you don't want Cucumber Unicode support
  require 'cucumber/formatter/unicode'

  require 'spec/rails'
  require 'cucumber/rails/rspec'         
  
end
 
Spork.each_run do
  # This code will be run each time you run your specs.
  require 'cucumber/rails/world'   
  require 'email_spec/cucumber'
 
  CachedCard.set_cache_prefix "#{System.host}/test"
  CachedCard.bump_global_seq
  CachedCard.set_cache_prefix "#{System.host}/cucumber"
  CachedCard.bump_global_seq

  Before do
    CachedCard.bump_global_seq
  end 

  # Comment out the next line if you don't want transactions to
  # open/roll back around each scenario
  Cucumber::Rails.use_transactional_fixtures

  # Comment out the next line if you want Rails' own error handling
  # (e.g. rescue_action_in_public / rescue_responses / rescue_from)
  Cucumber::Rails.bypass_rescue
end