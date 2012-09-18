require File.expand_path('../test_helper', File.dirname(__FILE__))

class BasicRenderingTest < ActionController::IntegrationTest

  #these tests are increasingly lame.

  test_render "card/changes/:id"        , :users=>{ :anonymous=>200, :joe_user=>200 }
  test_render "card/read/:id"           , :users=>{ :anonymous=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/options/:id"        , :users=>{ :anonymous=>200, :joe_user=>200 }, :cardtypes=>:all
  # joe doesn't have permission to edit account_requests, so test edit as admin for now.
  # later should have cardtype-specific permissions settings
  test_render "card/edit/:id"           , :users=>{ :anonymous=>403, :joe_admin=>200 }, :cardtypes=>:all
  test_render "card/new"                , :users=>{ :anonymous=>403, :joe_user=>200 }
end
