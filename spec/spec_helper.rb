require 'spork'
ENV["RAILS_ENV"] ||= 'test'

Spork.prefork do
  require File.expand_path File.dirname(__FILE__) + "/../config/environment"
  require File.expand_path File.dirname(__FILE__) + "/../lib/authenticated_test_helper.rb"
#  require File.expand_path File.dirname(__FILE__) + "/../lib/util/card_builder.rb"
  require File.expand_path File.dirname(__FILE__) + "/../lib/chunk_manager.rb"
  require File.expand_path File.dirname(__FILE__) + "/./helpers/chunk_spec_helper.rb"
  require 'rspec/rails'


  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'

  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers, :example_group => {
      :file_path => /\bspec\/controllers\// }

    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers
    config.include AuthenticatedTestHelper, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rr

    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false

    config.before(:each) do
      Wagn::Cache.restore
    end
    config.after(:each) do
      Timecop.return
    end
  end
end


Spork.each_run do
  # This code will be run each time you run your specs.
end
