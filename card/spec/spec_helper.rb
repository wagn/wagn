# -*- encoding : utf-8 -*-

require File.expand_path("../support/card_spec_loader.rb", __FILE__)
CardSpecLoader.init

require "rr"

# used for SharedData::Users - required here so code won't show up in coverage
require File.expand_path("../../db/seed/test/seed.rb", __FILE__)

CardSpecLoader.prefork do
  FIXTURES_PATH = File.expand_path("../../db/seed/test/fixtures", __FILE__)

  CardSpecLoader.rspec_config do |config|
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

  Card["*all+*style"].ensure_machine_output
  Card["*all+*script"].ensure_machine_output
  (ie9 = Card[:script_html5shiv_printshiv]) && ie9.ensure_machine_output
end

CardSpecLoader.each_run do
  # This code will be run each time you run your specs.
  require "simplecov"
end

CardSpecLoader.helper

class ActiveSupport::Logger
  def rspec msg, console_text=nil
    if Thread.current["logger-output"]
      Thread.current["logger-output"] << msg
    else
      puts console_text || msg
    end
  end
end
