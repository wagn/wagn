require File.expand_path('../test_helper', File.dirname(__FILE__))

require 'card_controller'

class CardController 
  def rescue_action(e) raise e end 
end


class AccountTest < ActionController::IntegrationTest    
  include LocationHelper

  def test_return_to_home_page_after_login
    post '/account/signin', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/'
  end
  
  def test_return_to_special_url_when_logging_in_after_visit
    get '/recent'
    post '/account/signin', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/*recent'
  end

end
