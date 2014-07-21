# -*- encoding : utf-8 -*-
<% if options['mod-dev'] || options['core-dev'] %>
# add this line to default to production mode
# ENV['RAILS_ENV'] ||= 'production'  
<% else %>
# comment out this line to default to development mode
ENV['RAILS_ENV'] ||= 'production'
<% end %>

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")


require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
