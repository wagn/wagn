require 'lib/util/card_builder.rb'
module WagnTestHelper
      
  include CardBuilderMethods
 
  def setup_default_user
    User.clear_cache
    
    # FIXME: should login as joe_user by default-- see what havoc it creates...
    @user = User.current_user = User.admin

    #@user.update_attribute('crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c')
    #@user.password="wagbot_pass"
    @user.roles << Role.find_by_codename('admin')
    
    # setup admin while we're at it
    @admin = User[:wagbot]

    @ra = Role.find_by_codename('admin')
    @admin.roles << @ra
    #User.current_user = User.find_by_login('joe_user')
  end
 
  def get_renderer()
    require 'renderer'
    Renderer.new
  end
  
  def given_cards( *definitions )   
    User.as(:joe_user) do 
      Card.create_these *definitions
    end
  end
  # 
  # 
  # def card( name )
  #   ::Card.find_by_name(name)
  # end
  
  def render( card )
    Renderer.new.render(card)
  end 
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  

  def integration_login_as(user)
    User.clear_cache
    
    case user.to_s 
      when 'anon'; #do nothing
      when 'joe_user'; login='joe@user.com'; pass='joe_pass'
      when 'admin';    login='u3@user.com'; pass='u3_pass'
      else raise "Don't know email & password for #{user}"
    end
    unless user==:anon
      # FIXME- does setting controller here break anything else?
      #tmp_controller = @controller
      #@controller = AccountController.new
      
      post '/user/signin', :login=>login, :password=>pass
      assert_response :redirect
      
      #@controller = tmp_controller
    end
    if block_given?
      yield
      post "/user/signout",:controller=>'user'
    end
  end
  
  def post_invite(options = {})
    action = options[:action] || :invite
    post action, 
      :user => { :email => 'new@user.com' }.merge(options[:user]||{}),
      :card => { :name => "New User" }.merge(options[:card]||{}),
      :email => { :subject => "mailit",  :message => "baby"  }
  end 
  
  def test_render(url)
    get url
    assert_response :success, "#{url} should render successfully"
  end 
  
  def test_action(url, args={})
    post url, *args
    assert_response :success
  end     
  
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
