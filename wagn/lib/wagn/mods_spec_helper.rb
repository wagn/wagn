# -*- encoding : utf-8 -*-
# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start

require "wagn" # only for card_gem_root
require File.join Wagn.card_gem_root, "spec/support/card_spec_loader.rb"

CardSpecLoader.init

CardSpecLoader.prefork do
  if defined?(Bundler)
    Bundler.require(:test)
    # if simplecov is activated in the Gemfile, it has to be required here
  end
  #  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CardSpecLoader.rspec_config
end

CardSpecLoader.each_run do
  # This code will be run each time you run your specs.
end

CardSpecLoader.helper
