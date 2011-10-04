#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

SampleRails::Application.load_tasks

=begin

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'


task :default => [:test, :spec, :features]

task :setup do
  if ENV['RUN_CODE_RUN']
    FileUtils.cp("config/sample_wagn.rb", "config/wagn.rb") unless File.exists?("config/wagn.rb")
  end
end

task :environment => :setup
=end  