require 'lib/util/card_builder.rb'
module WagnTestHelper
      
  include CardBuilderMethods
 
  def setup_default_user
    @user = User.current_user = User.find_by_login('admin')
    @user.update_attribute('crypted_password', '610bb7b564d468ad896e0fe4c3c5c919ea5cf16c')
    @user.roles << Role.find_by_codename('admin')
    
    # setup admin while we're at it
    @admin = User.find_by_login('admin')
    @ra = Role.find_by_codename('admin')
    @admin.roles << @ra
  end
 
  def test_renderer()
    require 'renderer'
    Renderer.instance
  end

  def card( name )
    ::Card.find_by_name(name)
  end
  
  def render( card )
    Renderer.new(Renderer::StubController.new).render(card)
  end 
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  def post_invite(options = {})
    post :create, 
      :user => { :email => 'new@user.com' }.merge(options[:user]||{}),
      :card => { :name => "New User" }.merge(options[:card]||{}),
      :email => { :subject => "mailit",  :message => "baby"  }
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

