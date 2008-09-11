# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
  
# needs to be loaded for all files, before migrations, etc.
#require "lib/wagn"         
                          
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  #RAILS_GEM_VERSION = '1.2.4' unless defined? RAILS_GEM_VERSION  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += ["#{RAILS_ROOT}/lib/imports", "#{RAILS_ROOT}"]

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  
  # FIXME observers weren't working right last time I tried -LWH 
  # hmm card observer seems to work... but not user_observer
  config.active_record.observers = :invitation_request_observer
  
  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'grave', 'graveyard'
  inflect.irregular 'this', 'this'     
  inflect.irregular 'anonymous', 'anonymous'
end
   
# Define a regexp function so the ~ WQL operator works with SQLite.
=begin
if ActiveRecord::Base.connection.adapter_name == "SQLite"
  ActiveRecord::Base.connection.raw_connection.create_function("regexp", 2) do |func, expr, arg|
    if arg.to_s =~ Regexp.new(expr.to_s)
      func.result = 1
    else
      func.result = 0
    end
  end
end
=end

  
# configure session store
Session = CGI::Session::ActiveRecordStore.session_class

# configure fragment store
#ActionController::Base.fragment_cache_store = :mem_cache_store #:memory_store #:file_store, "#{RAILS_ROOT}/../cache"
 
# force loading of the system model. FIXME: this seems like a terrible way to do this
System


# cached-model
require_dependency 'lib/cached_model'
CACHE = MemCache.new 'localhost:11211', :namespace => 'my_rails_app'
require_dependency 'lib/cache'                                      
CachedModel::use_local_cache=true



