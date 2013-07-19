# -*- encoding : utf-8 -*-
require 'spork'
ENV["RAILS_ENV"] = 'test'

module MySpecHelpers
  def render_test_card card
    format = Card::Format.new card
    format.add_name_context card.name
    format.process_content
  end

  def newcard(name, content="")
    Card.create! :name=>name, :content=>content
  end
end

Spork.prefork do
  require File.expand_path File.dirname(__FILE__) + "/../../config/environment"
  require File.expand_path File.dirname(__FILE__) + "/authenticated_test_helper"
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'

  RSpec.configure do |config|

    config.include RSpec::Rails::Matchers::RoutingMatchers, :example_group => {
      :file_path => /\bspec\/controllers\// }

    #config.include CustomMatchers
    #config.include ControllerMacros, :type=>:controllers
    config.include Wagn::AuthenticatedTestHelper, :type=>:controllers

    # == Mock Framework
    # If you prefer to mock with mocha, flexmock or RR, uncomment the appropriate symbol:
    # :mocha, :flexmock, :rr

    config.mock_with :rr

    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false


    config.before(:each) do
      Wagn::Cache.restore
    end
    config.after(:each) do
      Timecop.return
    end
  end
end


Spork.each_run do
  # This code will be run each time you run your specs.
end

=begin


  def get_format()
    Card::Format.new(Card.new(:name=>'dummy'))
  end

  def given_card( *card_args )
    Account.as_bot do
      Card.create *card_args
    end
  end


  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end

  USERS = {
    'joe@user.com' => 'joe_pass',
    'joe@admin.com' => 'joe_pass',
    'u3@user.com' => 'u3_pass'
  }

  def integration_login_as(user, functional=nil)
    raise "Don't know email & password for #{user}" unless uc=Card[user] and
        u=Account[ uc.id ] and
        login = u.email and pass = USERS[login]

    if functional
      #warn "functional login #{login}, #{pass}"
      post :signin, :login=>login, :password=>pass, :controller=>:account
    else
      #warn "integration login #{login}, #{pass}"
      post 'account/signin', :login=>login, :password=>pass, :controller=>:account
    end
    assert_response :redirect

    if block_given?
      yield
      post 'account/signout',:controller=>'account'
    end
  end

  def post_invite(options = {})
    action = options[:action] || :invite
    post action,
      :account => { :email => 'new@user.com' }.merge(options[:account]||{}),
      :card => { :name => "New User" }.merge(options[:card]||{}),
      :email => { :subject => "mailit",  :message => "baby"  }
  end

#  def test_render(url)
#    get url
#    assert_response :success, "#{url} should render successfully"
#  end

#  def test_action(url, args={})
#    post( url, *args )
#    assert_response :success
#  end

  def assert_rjs_redirected_to(url)
    assert @response.body.match(/window\.location\.href = \"([^\"]+)\";/)
    assert_equal $~[1], url
  end
end

module Test
  module Unit
    module Assertions
      def assert_success(bypass_content_parsing = false)
        assert_response :success
        unless bypass_content_parsing
          assert_nothing_raised(@response.content) { REXML::Document.new(@response.content) }
        end
      end
    end
  end
end
=end
