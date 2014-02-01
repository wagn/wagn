# -*- encoding : utf-8 -*-
# comment out this line to default to development mode
ENV['RAILS_ENV'] ||= 'production'

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")


require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
