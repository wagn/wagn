# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
  
# needs to be loaded for all files, before migrations, etc.
#require "lib/wagn"         
#ActiveRecord::Base.logger.info("after boot, before config")

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION  

  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += ["#{RAILS_ROOT}/lib/imports", "#{RAILS_ROOT}"]

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options   
  
  #config.gem "rspec-rails", :lib => "spec"          
  config.gem "uuid"
  config.gem "json"

  require 'yaml'   
  require 'erb'     
  database_configuration_file = 'config/database.yml'
  db = YAML::load(ERB.new(IO.read(database_configuration_file)).result)
  config.action_controller.session = {
    :session_key => db[RAILS_ENV]['session_key'],
    :secret      => db[RAILS_ENV]['secret']
  }  
end
   

#ExceptionNotifier.exception_recipients = %w(someone@somewhere.org)
#ExceptionNotifier.sender_address = %("#{System.site_name} Error" <notifier@wagn.org>)
#ExceptionNotifier.email_prefix = "[#{System.site_name}] "


# force loading of the system model. 
System

# ****************************************************
# IMPORTANT!!!:  YOU CANNOT PUT System.settings here
#  they will get LOST when System reloads in development environment. 
#   put them in wagn.rb instead.
# ****************************************************
