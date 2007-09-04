require "#{File.dirname(__FILE__)}/../test_helper"

class BasicRenderingTest < ActionController::IntegrationTest
  common_fixtures

  test_render "card/view/:id"           , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/line/:id"           , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/options/:id"        , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/changes/:id"        , :users=>{ :anon=>200, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/edit/:id"           , :users=>{ :anon=>403, :joe_user=>200 }, :cardtypes=>:all
  test_render "card/new"                , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "card/confirm_remove/:id" , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "connection/new/:id"      , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "connection/tag_cloud/:id", :users=>{ :anon=>403, :joe_user=>200 }
  test_render "options/roles/:id"       , :users=>{ :anon=>403, :joe_user=>200 }, :cardtypes=>['User']
  test_render "cardtype/view"           , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardtype/edit"           , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardtype/view/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardtype/edit/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardname/edit"           , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardname/view/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardname/edit/:id"       , :users=>{ :anon=>403, :joe_user=>200 }
  test_render "cardname/confirm/:id"    , :users=>{ :anon=>403, :joe_user=>200 }

=begin  

test_render "block/render_list/:id?query=recent_changes"
test_render "block/recent_list/:id?query=recent_changes"
test_render "block/search_list/:id?query=recent_changes"
test_render "block/connection_list/:id?query=recent_changes"
test_render "block/link_list/:id?query=recent_changes"

  def test_should_do_some_action
    test_action "card/update"
    test_action "card/save_draft"
    test_action "card/rollback"
    test_action "card/create"
    test_action "card/remove"
    test_action "card/comment"

    test_action "connection/create"
    test_action "connection/remove"
    
    test_action "options/update_roles"
  end 
=end
  
end
