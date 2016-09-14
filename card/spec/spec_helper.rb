# -*- encoding : utf-8 -*-

require File.expand_path("../support/spec_loader.rb", __FILE__)
SpecLoader.init

require "rr"

# used for SharedData::Users - required here so code won't show up in coverage
require File.expand_path("../../db/seed/test/seed.rb", __FILE__)

require File.expand_path("../../config/simplecov_helper.rb", __FILE__)
require "simplecov"

SpecLoader.prefork do
  FIXTURES_PATH = File.expand_path("../../db/seed/test/fixtures", __FILE__)

  JOE_USER_ID = Card["joe_user"].id

  SpecLoader.rspec_config do |config|
    # require 'card-rspec-formatter'
    config.mock_with :rr

    config.mock_with :rspec do |mocks|
      mocks.syntax = [:should, :expect]
      mocks.verify_partial_doubles = true
    end
    config.expect_with :rspec do |c|
      c.syntax = [:should, :expect]
    end
  end
end

Card["*all+*style"].ensure_machine_output
Card["*all+*script"].ensure_machine_output
(ie9 = Card[:script_html5shiv_printshiv]) && ie9.ensure_machine_output



Spork.each_run do
  # This code will be run each time you run your specs.
end

SpecLoader.card_helper

class ActiveSupport::Logger
  def rspec msg
    Thread.current["logger-output"] << msg
  end
end
