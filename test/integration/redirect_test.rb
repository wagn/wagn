require File.dirname(__FILE__) + '/../test_helper'

require 'card_controller'

class CardController 
  def rescue_action(e) raise e end 
end


class RedirectTest < ActionController::IntegrationTest    
  include LocationHelper
  
  def test_return_to_home_page_after_login
    post '/account/login', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/'
  end
  
  def test_return_to_special_url_when_logging_in_after_visit
    get '/recent'
    post '/account/login', :login=>'joe@user.com', :password=>'joe_pass'
    assert_redirected_to '/recent'
  end
  
  def test_return_to_previous_undeleted_card_after_deletion
    t1, t2 = given_cards "Testable1"=>"hello", "Testable2"=>"world"    
    
    post '/account/login', :login=>'joe@user.com', :password=>'joe_pass'
    get url_for_page( t1.name )
    get url_for_page( t2.name )
    
    post 'card/remove/' + t2.id.to_s
    assert_redirected_to url_for_page( t1.name )
    
    post 'card/remove/' + t1.id.to_s
    assert_redirected_to '/'
  end
end