require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActionController::IntegrationTest
  common_fixtures
=begin  
  def test_activate
    u = User.new
    invitor = User.find(:first)
    u.setup_as_invitee( invitor, 'test@blogzilla.org' )
    assert( code = u.activation_code, "activation_code not null" )

    post "/account/activate/#{u.activation_code}",  :user => {
        :password=>'bottle43',
        :password_confirmation=>'bottle43',
        :email => 'teser@booga.org'
      },  :tag => {:name => "Word Number One" }
    assert_response :redirect
  end 
=end
end
