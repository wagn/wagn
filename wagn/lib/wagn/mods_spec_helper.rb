# -*- encoding : utf-8 -*-
# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start

require File.expand_path "../../../../card/spec/spec_loader.rb", __FILE__
SpecLoader.init

SpecLoader.prefork do
  require File.join Cardio.gem_root, "config", "simplecov_helper.rb"
  if defined?(Bundler)
    Bundler.require(:test)   # if simplecov is activated in the Gemfile, it has to be required here
  end

  #  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card["joe_user"].id
  SpecLoader.rspec_config
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

SpecLoader.card_helper
