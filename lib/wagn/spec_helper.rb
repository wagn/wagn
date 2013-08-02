# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'

Spork.prefork do
  require File.expand_path File.dirname(__FILE__) + "/../../config/environment"
  require File.expand_path File.dirname(__FILE__) + "/authenticated_test_helper"
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card['joe_user'].id

  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers, :example_group => {
      :file_path => /\bspec\/controllers\// }

    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers
    config.include Wagn::AuthenticatedTestHelper, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false


    config.before(:each) do
      Account.current_id = JOE_USER_ID
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


