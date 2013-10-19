# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'

Spork.prefork do
  require File.expand_path File.dirname(__FILE__) + "/../../config/environment"
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  JOE_USER_ID = Card['joe_user'].id

  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers, :example_group => {
      :file_path => /\bspec\/controllers\// }

    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false


    config.before(:each) do
      Account.current_id = JOE_USER_ID
      Wagn::Cache.restore
      Wagn::Env.reset
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
    Account.current_id = @request.session[:user] = (uc=Card[user.to_s] and uc.id)
    #warn "(ath)login_as #{user.inspect}, #{Account.current_id}, #{@request.session[:user]}"
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
    Card::Format.new(card).render(:edit)
  end

  def render_content content, format_args={}
    @card ||= Card.new :name=>"Tempo Rary 2"
    @card.content = content
    f = Card::Format.new @card, format_args
    f._render :core
  end

  def render_card view, card_args={}, format_args={}
    card = begin
      if card_args[:name]
        Card.fetch card_args[:name], :new=>card_args
      else
        Card.new card_args.merge( :name=> 'Tempo Rary' )
      end
    end
    Card::Format.new(card, format_args)._render(view)
  end
end

RSpec::Core::ExampleGroup.send :include, Wagn::SpecHelper

