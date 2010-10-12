require 'rubygems'
require 'spork'
ENV["RAILS_ENV"] = "test"
require 'assert2/xhtml'

Spork.prefork do
  require File.expand_path(File.dirname(__FILE__) + "/../config/wagn_initializer")
  Spork.trap_class_method(Wagn::Initializer,"load")

  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'spec'
  require 'spec/autorun'
  require 'spec/rails' 
  
  require "email_spec"
  
  
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.

  Spec::Runner.configure do |config|
    # If you're not using ActiveRecord you should remove these
    # lines, delete config/database.yml and disable :active_record
    # in your config/boot.rb
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
           
    config.include AuthenticatedTestHelper, :type=>:controllers      
    # == Notes
    # 
    # For more information take a look at Spec::Example::Configuration and Spec::Runner
    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
    
    config.before(:each) do
      # old cache stuff
      Wagn::Cache.reset_local
      Wagn::Cache.reset_global

      # new cache stuff
      Wagn.cache.reset
      Card.cache.reset_local
    end

    config.after(:each) do
#      Wagn::Cache.reset_local
#      Wagn::Cache.reset_global
#
#      Wagn.cache.reset
#      Card.cache.reset_local
    end
  end
end

Spork.each_run do     
  # This code will be run each time you run your specs.
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




