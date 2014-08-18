# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'

def simplecov_filter_for_gem
  filters.clear # This will remove the :root_filter that comes via simplecov's defaults
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}/) unless src.filename =~ /wagn/
  end    
  
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/tasks/'
  add_filter '/generators/'
  add_filter 'lib/wagn'

  add_group 'Card', 'lib/card'  
  add_group 'Set Patterns', 'tmp/set_pattern/'
  add_group 'Sets',         'tmp/set/'
  add_group 'Formats' do |src_file|
    src_file.filename =~ /mod\/[^\/]+\/format/
  end
  add_group 'Chunks' do |src_file|
    src_file.filename =~ /mod\/[^\/]+\/chunk/
  end
end

require 'simplecov'
require 'timecop'
require File.expand_path( '../../spec/mod/standard/lib/machine_spec.rb', __FILE__ )
require File.expand_path( '../../spec/mod/standard/lib/machine_input_spec.rb', __FILE__ )

Spork.prefork do
  if ENV["RAILS_ROOT"]
    require File.join( ENV["RAILS_ROOT"], '/config/environment')
  else
    require File.expand_path( '../../config/environment', __FILE__ )
  end
  
  require 'rspec/rails'
  require File.expand_path( '../../lib/wagn/wagn_spec_helper.rb', __FILE__ )
  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
#  Dir[ File.join(Wagn.gem_root, "spec/support/**/*.rb") ].each { |f| require f }

#  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card['joe_user'].id

  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers, :example_group => {
      :file_path => /\bspec\/controllers\//
    }

    format_index = ARGV.find_index {|arg| arg =~ /--format/ }
    formatter = format_index ? ARGV[ format_index + 1 ] : 'documentation'
    config.add_formatter formatter
    
    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    

    config.before(:each) do
      Card::Auth.current_id = JOE_USER_ID
      Wagn::Cache.restore
      Card::Env.reset
    end
    config.after(:each) do
      Timecop.return
    end
  end
end

Card['*all+*style' ].ensure_machine_output
Card['*all+*script'].ensure_machine_output


Spork.each_run do

  # This code will be run each time you run your specs.
end


class Card
  def self.gimme! name, args = {}
    Card::Auth.as_bot do
      c = Card.fetch( name, :new => args )
      c.putty args
      Card.fetch name 
    end    
  end
  
  def self.gimme name, args = {}
    Card::Auth.as_bot do
      c = Card.fetch( name, :new => args )
      if args[:content] and c.content != args[:content]
        c.putty args
        c = Card.fetch name 
      end
      c
    end    
  end
  
  def putty args = {}
    Card::Auth.as_bot do
      if args.present? 
        update_attributes! (args) 
      else 
        save!
      end
    end
  end
end

RSpec::Core::ExampleGroup.send :include, Wagn::WagnSpecHelper

