#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../lib/wagn/application', __FILE__)

Wagn::Application.load_tasks

=begin
#require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "wagn"
  gem.homepage = "http://github.com/wagn/wagn"
  gem.license = "GPL"
  gem.summary = %Q{Wagn: team-driven websites }
  gem.description = %Q{Create dynamic web systems with wiki-inspired building blocks.}
  gem.email = "ethan@grasscommons.org"
  gem.authors = ["Ethan McCutchen","Lewis Hoffman","Gerry Gleason"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
=end
