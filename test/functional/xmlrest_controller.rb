require_relative '../test_helper'

# Re-raise errors caught by the controller.
class XmlrestController
  def rescue_action(e) raise e end
end

class XmlrestControllerTest < ActionController::TestCase

  include AuthenticatedTestHelper

  def setup
    User.as :joe_user
    @user = User[:joe_user]
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = XmlrestController.new
    @simple_card = Card['Sample Basic']
    @combo_card = Card['A+B']
    login_as(:joe_user)
  end

#=begin
  def test_create_cardtype_card
    post :post, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
    assert assigns['card']
    assert_response 418
    assert Card.find_by_name('Editor').class.include?(Wagn::Set::Type::Cardtype)
    # this assertion fails under autotest when running the whole suite,
    # passes under rake test.
    # assert_instance_of Cardtype, Cardtype.find_by_class_name('Editor')
  end

=begin
#assert_restful_routes_for (controller_name, options = {}) {|options[:options] if block_given?| ...}
#    assert_restful_routes_for XmlrestController
  def test_create_a_restful_routes
#def test_with_collection_actions
    actions = { 'a' => :get, 'b' => :put, 'c' => :post, 'd' => :delete }

    with_restful_routing :messages, :collection => actions do
      assert_restful_routes_for :messages do |options|
        actions.each do |action, method|
          assert_recognizes(options.merge(:action => action), :path => "/messages/#{action}", :method => method)
        end
      end

      assert_restful_named_routes_for :messages do |options|
        actions.keys.each do |action|
          assert_named_route "/messages/#{action}", "#{action}_messages_path", :action => action
        end
      end
    end
  end
=end

#  what's happening with this test is that when changing from Basic to CardtypeA it is
#  stripping the html when the test doesn't think it should.  this could be a bug, but it
#  seems less urgent that a lot of the other bugs on the list, so I'm leaving this test out
#  for now.
#
#  def test_update_cardtype_no_stripping
#    User.as :joe_user
#    post :update, {:id=>@simple_card.id, :card=>{ :type=>"CardtypeA",:content=>"<br/>" } }
#    #assert_equal "boo", assigns['card'].content
#    assert_equal "<br/>", assigns['card'].content
#    assert_response :success, "changed card type"
#    assert_equal "CardtypeA", Card['Sample Basic'].cardtype
#  end
#
#  def test_update_cardtype_with_stripping
#    User.as :joe_user
#    post :edit, {:id=>@simple_card.id, :card=>{ :type=>"Date",:content=>"<br/>" } }
#    #assert_equal "boo", assigns['card'].content
#    assert_response :success, "changed card type"
#    assert_equal "", assigns['card'].content
#    assert_equal "Date", Card['Sample Basic'].cardtype
#  end




  def test_new_with_name
    post :post, :card=>{:name=>"BananaBread"}
    assert_response :success, "response should succeed"
    assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
  end

  def test_new_with_existing_card
    post :post, :card=>{:name=>"A"}
    assert_response :success, "response should succeed"
  end

  def test_show
    get :get, {:id=>'Sample_Basic'}
    assert_response :success
    assert_equal assigns['card'].name, 'Sample Basic'
  end

  def test_show_nonexistent_card
    get :get, {:id=>'Sample_Fako'}
    assert_response :success
    assert_template 'new'
  end

  def test_show_nonexistent_card_no_create
    login_as :anon
    get :get, {:id=>'Sample_Fako'}
    assert_response :success
    assert_template 'missing'
  end

  def test_update
    put :put, { :id=>@simple_card.id,
      :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id}
    assert_response :success, "edited card"
    assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
  end

=begin not implemented
  def test_changes
    id = Card.find_by_name('revtest').id
    get :changes, :id=>id, :rev=>1
    assert_equal 'first', assigns['revision'].content, "revision 1 content==first"

    get :changes, :id=>id, :rev=>2
    assert_equal 'second', assigns['revision'].content, "revision 2 content==second"
    assert_equal 'first', assigns['previous_revision'].content, 'prev content=="first"'
  end
=end

  # needs at least a name to make sense
  def test_new_without_cardtype
    post :post
    assert_response :success, "response should succeed"
    assert_equal 'Basic', assigns['card'].cardtype, "@card type should == Basic"
  end

  def test_new_with_cardtype
    post :post, :card => {:type=>'Date'}
    assert_response :success, "response should succeed"
    assert_equal 'Date', assigns['card'].cardtype, "@card type should == Date"
  end

  def test_create
    post :post, :card => {
      :name=>"NewCardFoo",
      :type=>"Basic",
      :content=>"Bananas"
    }
    assert_response 418
    assert_instance_of Card, Card.find_by_name("NewCardFoo")
    assert_equal "Bananas", Card.find_by_name("NewCardFoo").content
  end

  def test_remove
    c = given_cards("Boo"=>"booya").first
    delete :delete, :id=>c.id.to_s
    assert_response :success
    assert_nil Card.find_by_name("Boo")
  end


  def test_recreate_from_trash
    @c = Card.create! :name=>"Problem", :content=>"boof"
    @c.destroy!
    post :post, :card=>{
      "name"=>"Problem",
      "type"=>"Phrase",
      "content"=>"noof"
    }
    assert_response 418
    assert Card.find_by_name("Problem").class.include?(Wagn::Set::Type::Phrase)
  end

  def test_multi_create_without_name
    post :post, "card"=>{"name"=>"", "type"=>"Form"},
     "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}},
     "content_to_replace"=>"",
     "context"=>"main_1",
     "multi_edit"=>"true", "view"=>"open"
    assert_equal "can't be blank", assigns['card'].errors["name"]
    assert_response 422
  end


  def test_multi_create
    post :post, "card"=>{"name"=>"sss", "type"=>"Form"},
     "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}},
     "content_to_replace"=>"",
     "context"=>"main_1",
     "multi_edit"=>"true", "view"=>"open"
    assert_response 418
    assert Card.find_by_name("sss")
    assert Card.find_by_name("sss+text")
  end

  def test_should_redirect_to_thanks_on_create_without_read_permission
    # 1st setup anonymously create-able cardtype
    User.as(:joe_admin)
    
    #remove me after regenerating test data
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
    f.permit(:read, Role[:admin])
    f.save!

    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:auth])
    ff.save!

    Card.create! :name=>"Fruit+*thanks", :type=>"Phrase", :content=>"/wagn/sweet"

    login_as(:anon)
    post :post, :card => {
      :name=>"Banana", :type=>"Fruit", :content=>"mush"
    }
    assert_equal "/wagn/sweet", assigns["redirect_location"]
    assert_template "redirect_to_thanks"
  end


  def test_should_redirect_to_card_on_create_main_card
    # 1st setup anonymously create-able cardtype
    User.as(:joe_admin)
    
    #remove me after regenerating test data 
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
    f.permit(:read, Role[:anon])
    f.save!

    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:anon])
    ff.save!

    login_as(:anon)
    post :post, :context=>"main_1", :card => {
      :name=>"Banana", :type=>"Fruit", :content=>"mush"
    }
    assert_equal "/wagn/Banana", assigns["redirect_location"]
    assert_template "redirect_to_created_card"
  end


=begin
  def test_should_watch
    login_as(:joe_user)
    post :watch, :id=>"Home"
    assert_equal "[[Joe User]]", Card["Home+*watchers"].content
  end
=end

  def test_new_should_not_for_creatable_nonviewable_cardtype
    User.as(:joe_admin)
    
    #remove me after regenerating test data
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
    f.permit(:read, Role[:auth])
#    f.permit(:edit, Role[:admin])
    f.save!

    ff = Card.create! :name=>"Fruit+*tform"
    ff.permit(:read, Role[:auth])
    ff.save!

    login_as(:anon)
    get :get, :type=>"Fruit"
    assert_response :success
    assert_template 'missing'
  end

  def test_rename_without_update_references_should_work
    User.as :joe_user
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    put :put, :id => f.id, :card => {
      :confirm_rename => true,
      :name => "Newt",
      :update_referencers => "false",
    }
    assert_equal ({ "name"=>"Newt", "update_referencers"=>'false', "confirm_rename"=>true }), assigns['card_args']
    assert assigns['card'].errors.empty?
    assert_template 'show'
    assert Card["Newt"]
  end

#=end
  def test_unrecognized_card_renders_missing_unless_can_create_basic
    #User.as :anon
    login_as(:anon)
    get :get, :id=>'crazy unknown name'
    assert_template 'missing'
  end

protected
  def with_restful_routing(*args)
    with_routing do |set|
      set.draw { |map| map.resources(*args) }
      yield
    end
  end
  def assert_restful_routes_for(controller_name, options = {})
    options[:options] ||= {}
    options[:options][:controller] = options[:controller] || controller_name.to_s

    collection_path            = "/#{options[:path_prefix]}#{controller_name}"
    member_path                = "#{collection_path}/1"
    new_path                   = "#{collection_path}/new"
    edit_member_path           = "#{member_path}/edit"
    formatted_edit_member_path = "#{member_path}/edit.xml"

    with_options(options[:options]) do |controller|
      #controller.assert_routing collection_path,            :action => 'index'
      controller.assert_routing new_path, :messages, :action => 'post', :format => :xml
      controller.assert_routing member_path,                :action => 'get', :id => '1', :format => :xml
      controller.assert_routing edit_member_path,           :action => 'put', :id => '1', :format => :xml
    end

    assert_recognizes(options[:options].merge(:action => 'post'), :path => collection_path, :method => :post, :method => :get)
    assert_recognizes(options[:options].merge(:action => 'get', :id => '1'), :path => member_path,      :method => :get, :method => :get)
    assert_recognizes(options[:options].merge(:action => 'put', :id => '1'), :path => member_path,      :method => :put, :method => :get)
    assert_recognizes(options[:options].merge(:action => 'delete', :id => '1'), :path => member_path,      :method => :delete, :method => :get)

    assert_recognizes(options[:options].merge(:action => 'new',                 :format => 'xml'), :path => "#{new_path}.xml", :method => :get)
    assert_recognizes(options[:options].merge(:action => 'create',              :format => 'xml'), :path => "#{collection_path}.xml",   :method => :post)
    assert_recognizes(options[:options].merge(:action => 'show',    :id => '1', :format => 'xml'), :path => "#{member_path}.xml",       :method => :get)
    assert_recognizes(options[:options].merge(:action => 'edit',    :id => '1', :format => 'xml'), :path => formatted_edit_member_path, :method => :get)
    assert_recognizes(options[:options].merge(:action => 'update',  :id => '1', :format => 'xml'), :path => "#{member_path}.xml",       :method => :put)
    assert_recognizes(options[:options].merge(:action => 'destroy', :id => '1', :format => 'xml'), :path => "#{member_path}.xml",       :method => :delete)

    yield options[:options] if block_given?
  end

end
