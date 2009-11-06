require 'rubygems'
require 'spork'
        
 
 
Spork.prefork do
  # Sets up the Rails environment for Cucumber
  ENV["RAILS_ENV"] ||= "cucumber"
  #ActiveSupport::Dependencies.load_paths << "#{RAILS_ROOT}/app/addons"                      
  
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
   
  Cucumber::Rails::World.use_transactional_fixtures = true    
  
  # If you set this to false, any error raised from within your app will bubble 
  # up to your step definition and out to cucumber unless you catch it somewhere
  # on the way. You can make Rails rescue errors and render error pages on a
  # per-scenario basis by tagging a scenario or feature with the @allow-rescue tag.
  #
  # If you set this to true, Rails will rescue all errors and render error
  # pages, more or less in the same way your application would behave in the
  # default production environment. It's not recommended to do this for all
  # of your scenarios, as this makes it hard to discover errors in your application.
  ActionController::Base.allow_rescue = false
end