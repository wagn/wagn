# -*- encoding : utf-8 -*-

require 'rubygems'

# defaults to development mode without the following
<% if options['mod-dev'] || options['core-dev'] -%>
# ENV['RAILS_ENV'] ||= 'production'  
<% else -%>
ENV['RAILS_ENV'] ||= 'production'
<% end -%>

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
