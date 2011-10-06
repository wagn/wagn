require 'spork'
ENV["RAILS_ENV"] ||= 'test'
require 'assert2/xhtml'

Spork.prefork do
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'rspec/rails' 


  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    
    
    config.include AuthenticatedTestHelper, :type=>:controllers
    #config.include(EmailSpec::Helpers)
    #config.include(EmailSpec::Matchers)
    
    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
  
    config.before(:each) do
      Wagn::Cache.reset_for_tests
    end
  end
end


Spork.each_run do     
  # This code will be run each time you run your specs.
end