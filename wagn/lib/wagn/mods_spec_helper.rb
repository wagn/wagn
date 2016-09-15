# -*- encoding : utf-8 -*-
# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start

def locate_gem name
  spec = Bundler.load.specs.find{|s| s.name == name }
  unless spec
    raise GemNotFound, "Could not find gem '#{name}' in the current bundle."
  end
  return File.expand_path('../../../', __FILE__) if spec.name == 'bundler'
  spec.full_gem_path
end

require File.join locate_gem("card"), "/spec/support/card_spec_loader.rb"

Card::SpecLoader.init

Card::SpecLoader.prefork do
  require File.join Cardio.gem_root, "config", "simplecov_helper.rb"
  if defined?(Bundler)
    Bundler.require(:test)   # if simplecov is activated in the Gemfile, it has to be required here
  end

  #  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card["joe_user"].id
  Card::SpecLoader.rspec_config
end

Card::SpecLoader.each_run do
  # This code will be run each time you run your specs.
end

Card::SpecLoader.helper


