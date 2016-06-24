# -*- encoding : utf-8 -*-
require 'email_spec'
require 'email_spec/cucumber'

Capybara.configure do |config|
  config.match = :prefer_exact
end


Before('@no-txn,@selenium,@culerity,@celerity,@javascript') do
  # if ENV['RAILS_ROOT']
  #   require File.join(ENV['RAILS_ROOT'], '/config/environment')
  # else
  #   require File.expand_path('../../config/environment', __FILE__)
  # end
#  Cucumber::Rails::World.use_transactional_fixtures = false
  DatabaseCleaner.strategy = :transaction #, {except: %w[widgets]}
  Card::Cache.restore
end
#
Before('~@no-txn', '~@selenium', '~@culerity', '~@celerity',
       '~@javascript') do
  # if ENV['RAILS_ROOT']
  #   require File.join(ENV['RAILS_ROOT'], '/config/environment')
  # else
  #   require File.expand_path('../../config/environment', __FILE__)
  # end
  DatabaseCleaner.strategy = :transaction
  Card::Cache.restore
end
