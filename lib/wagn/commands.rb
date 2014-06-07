if ARGV.first == "seed"
  require File.expand_path('../../../config/application', __FILE__)
  require 'rake'
  WagnTest::Application.load_tasks
  Rake::Task['wagn:create'].invoke
else
  require 'wagn'
  require 'rails/commands'
end