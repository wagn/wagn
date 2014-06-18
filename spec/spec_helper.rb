# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'

require 'simplecov'
require 'byebug'
Spork.prefork do
  if ENV["RAILS_ROOT"].present?
    require File.join( ENV["RAILS_ROOT"], '/config/environment')
  else
    require File.expand_path( '../../config/environment', __FILE__ )
  end
  
  require 'rspec/rails'
  
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


Spork.each_run do

  # This code will be run each time you run your specs.
end

module Wagn::SpecHelper

  include ActionDispatch::Assertions::SelectorAssertions
  #~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
  
  def login_as user
    Card::Auth.current_id = (uc=Card[user.to_s] and uc.id)
    if @request
      @request.session[:user] = Card::Auth.current_id
    end
    #warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, #{@request.session[:user]}"
  end
  
  def newcard name, content=""
    #FIXME - misleading name; sounds like it doesn't save.
    Card.create! :name=>name, :content=>content
  end

  def assert_view_select(view_html, *args, &block)
    node = HTML::Document.new(view_html).root
    if block_given?
      assert_select node, *args, &block
    else
      assert_select node, *args
    end
  end

  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + #{rand(4)}", :type=>type)
    card.format.render(:edit)
  end

  def render_content content, format_args={}
    @card ||= Card.new :name=>"Tempo Rary 2"
    @card.content = content
    @card.format(format_args)._render :core
  end

  def render_card view, card_args={}, format_args={}
    card = begin
      if card_args[:name]
        Card.fetch card_args[:name], :new=>card_args
      else
        Card.new card_args.merge( :name=> 'Tempo Rary' )
      end
    end
    card.format(format_args)._render(view)
  end
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

RSpec::Core::ExampleGroup.send :include, Wagn::SpecHelper

