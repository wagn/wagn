require File.dirname(__FILE__) + '/../test_helper'

class CardViewTest < ActionController::IntegrationTest
  common_fixtures

  def setup
    setup_default_user
  end

  def test_user_roles
    card = Card::User.find :first
    get "/options/roles/#{card.id}"
    assert_response :success
  end
  
  def test_home 
    get "/"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template "card/show"
  end

  def test_login
    login
  end
  
  def test_standard_views
    login
    card = Card.find_by_trunk_id(nil)  # a simple card
    %w[view new options remove_form].each do |view|
      url = "/card/#{view}/#{card.id}"
      #warn "GETTING #{url}"
      get url
      assert_response :success, "get #{url}"
    end                     
  end                   
  
  def test_rename_form
    card = Card.find_by_trunk_id(nil)  # a simple card
    url = "/card/remove_form/#{card.id}?card[name]=newname"
    get url
    assert_response :success, "get #{url}"
  end
  
  
  def test_explain_connection
    
  end
  
  def test_revision
    
  end
  
  private
    def login
      # just admin for now.  later should do each role..
      post "/account/login", :login=>'webmaster@grasscommons.org', :password=>'w8gn8t0r'
      assert_response :redirect
    end
   
end
