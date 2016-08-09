# -*- encoding : utf-8 -*-
# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start
require "spork"

ENV["RAILS_ENV"] = "test"

Spork.prefork do
  if ENV["RAILS_ROOT"]
    require File.join(ENV["RAILS_ROOT"], "/config/environment")
  else
    require File.expand_path("../../config/environment", __FILE__)
  end
  require File.join Cardio.gem_root, "lib", "card", "simplecov_helper.rb"

  if defined?(Bundler)
    Bundler.require(:test)   # if simplecov is activated in the Gemfile, it has to be required here
  end

  require "rspec/rails"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  #  Dir[ File.join(Wagn.gem_root, "spec/support/**/*.rb") ].each { |f| require f }

  #  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card["joe_user"].id

  RSpec.configure do |config|
    config.include RSpec::Rails::Matchers::RoutingMatchers,        file_path: /\bspec\/controllers\//
    config.infer_spec_type_from_file_location!
    # format_index = ARGV.find_index {|arg| arg =~ /--format/ }
    # formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation'
    # config.add_formatter formatter

    # config.include CustomMatchers
    # config.include ControllerMacros, type: :controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    # config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false

    config.before(:each) do
      Card::Auth.current_id = JOE_USER_ID
      Card::Cache.restore
      Card::Env.reset
    end
    config.after(:each) do
      Timecop.return
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

require File.join Cardio.gem_root, "lib", "card", "spec_helper.rb"

RSpec::Core::ExampleGroup.send :include, Card::SpecHelper
