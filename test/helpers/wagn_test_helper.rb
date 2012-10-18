require "#{Rails.root}/lib/util/card_builder.rb"
#require 'renderer'

module WagnTestHelper

  include CardBuilderMethods

  def setup_default_user
    User.cache.reset

    user_card = Card['joe user'] #Card[Card::WagnBotID]
    user_card = Card[:wagn_bot]
    Session.user= user_card.id
    @user = Session.user
    #STDERR << "user #{user_card.inspect}\n"

    @user.update_column 'crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c'
    #user_card.trait_card(:roles) << Card::AdminID

    # setup admin while we're at it
    #@admin_card = Card[Card::WagnBotID]

    #@admin_card.trait_card(:roles) << Card::AdminID
    Session.user = 'joe_user'
    nil
  end

  def get_renderer()
    Wagn::Renderer.new(Card.new(:name=>'dummy'))
  end

  def given_card( *card_args )
    Session.as_bot do
      Card.create *card_args
    end
  end


  def render_test_card( card )
    r = Wagn::Renderer.new(card)
    r.add_name_context card.name
    r.process_content()
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
    User.cache.reset

    raise "Don't know email & password for #{user}" unless uc=Card[user] and
        u=User.where(:card_id=>uc.id).first and
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
      :user => { :email => 'new@user.com' }.merge(options[:user]||{}),
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
