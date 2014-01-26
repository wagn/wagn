# -*- encoding : utf-8 -*-
require 'wagn/conf'

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")


require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
