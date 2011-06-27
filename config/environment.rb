# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), 'wagn_initializer')
  
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  #RAILS_GEM_VERSION = '2.3.9' unless defined? RAILS_GEM_VERSION  
     
  Wagn::Initializer.set_default_rails_config config

  # Skip frameworks you're not going to use

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  config.log_level = :debug

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  #config.gem 'localmemcache_store', :source => 'http://gemcutter.org'
  #config.cache_store = :localmemcache_store, { :namespace => 'testapp', :size_mb => 256 }
  
  # See Rails::Configuration for more options   
  # select a store for the rails/card cache
end

#STDERR << "Loaded? #{Module.const_defined?(:Rails)}\n"
ActionController::Dispatcher.to_prepare do
  #STDERR << "\n\nto_prepare\n\n"
  Wagn::Initializer.run
end

Wagn::Initializer.load_modules
