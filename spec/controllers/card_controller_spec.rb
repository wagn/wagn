require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper

describe CardController do

  describe "- route generation" do
#  not sure we want this.
#    it "gets name/id from /new/xxx" do
#      {:post=> "/new/xxx"}.should route_to(
#        :controller=>"card", :action=>'new', :id=>"xxx"
#      )
#    end

    it "should recognize type" do
      { :get => "/new/Phrase" }.should route_to( :controller => 'card', :action=>'read', :type=>'Phrase', :view=>'new' )
    end

    it "should recognize .rss on /recent" do
      {:get => "/recent.rss"}.should route_to(:controller=>"card", :view=>"content", :action=>"read",
        :id=>"*recent", :format=>"rss"
      )
    end

    ["/wagn",""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          {:get => "#{prefix}/*recent.rss"}.should route_to(
            :controller=>"card", :action=>"read", :id=>"*recent", :format=>"rss"
          )
        end

        it "should recognize .xml format" do
          {:get => "#{prefix}/*recent.xml"}.should route_to(
            :controller=>"card", :action=>"read", :id=>"*recent", :format=>"xml"
          )
        end

#        it "should accept cards with dot sections that don't match extensions" do
#          {:get => "#{prefix}/random.card"}.should route_to(
#            :controller=>"card",:action=>"action",:id=>"random.card"
#          )
#        end

        it "should accept cards without dots" do
          {:get => "#{prefix}/random"}.should route_to(
            :controller=>"card",:action=>"read",:id=>"random"
          )
        end
      end
    end
  end

  describe "#create" do
    before do
      login_as 'joe_user'
    end

    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.
    it "creates cards" do
      post :action, :card => {
        :name=>"NewCardFoo",
        :type=>"Basic",
        :content=>"Bananas"
      }
      assert_response 302
      c=Card["NewCardFoo"]
      c.typecode.should == :basic
      c.content.should == "Bananas"
    end


    it "creates cardtype cards" do
      xhr :post, :action, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
      assigns['card'].should_not be_nil
      assert_response 200
      c=Card["Editor"]
      c.typecode.should == :cardtype
    end

    it "pulls deleted cards from trash" do
      @c = Card.create! :name=>"Problem", :content=>"boof"
      @c.destroy!
      post :action, :card=>{"name"=>"Problem","type"=>"Phrase","content"=>"noof"}
      assert_response 302
      c=Card["Problem"]
      c.typecode.should == :phrase
    end

    context "multi-create" do
      it "catches missing name error" do
        post :action, "card"=>{
            "name"=>"",
            "type"=>"Fruit",
            "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}
          }, "view"=>"open"
        Rails.logger.warn "testing a"
        assigns['card'].errors[:key].first.should == "cannot be blank"
        assigns['card'].errors[:name].first.should == "can't be blank"
        assert_response 422
      end

      it "creates card with subcards" do
        login_as 'joe_admin'
        xhr :post, :action, :success=>'REDIRECT: /', :card=>{
          :name  => "Gala",
          :type  => "Fruit",
          :cards => {
            "~plus~kind"  => { :content => "apple"} ,
            "~plus~color" => { :type=>'Phrase', :content => "red"  }
          }
        }
        assert_response 303
        Card["Gala"].should_not be_nil
        Card["Gala+kind"].content.should == 'apple'
        Card["Gala+color"].type_name.should == 'Phrase'
      end
    end

    it "renders errors if create fails" do
      post :create, "card"=>{"name"=>"Joe User"}
      assert_response 422
    end

    it "redirects to thanks if present" do
      login_as 'joe_admin'
      xhr :post, :create, :success => 'REDIRECT: /thank_you', :card => { "name" => "Wombly" }
      assert_response 303, "/thank_you"
    end

    it "redirects to card if thanks is blank" do
      login_as 'joe_admin'
      post :create, :success => 'REDIRECT: _self', "card" => { "name" => "Joe+boop" }
      assert_redirected_to "/Joe+boop"
    end

    it "redirects to previous" do
      # Fruits (from shared_data) are anon creatable but not readable
      login_as :anonymous
      post :create, { :success=>'REDIRECT: *previous', "card" => { "type"=>"Fruit", :name=>"papaya" } }, :history=>['/blam']
      assert_redirected_to "/blam"
    end
  end

  describe "view = new" do
    before do
      login_as 'joe_user'
    end

    it "new should work for creatable nonviewable cardtype" do
      login_as(:anonymous)
      get :read, :type=>"Fruit", :view=>'new'
      assert_response :success
    end

    it "new with existing card" do
      get :read, :card=>{:name=>"A"}, :view=>'new'
      assert_response :success, "response should succeed"
    end
  end

  describe "unit tests" do
    include AuthenticatedTestHelper

    before do
      Account.as 'joe_user'
      @user = User['joe_user']
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @controller = CardController.new
      @simple_card = Card['Sample Basic']
      @combo_card = Card['A+B']
      login_as('joe_user')
    end

    it "new with name" do
      post :read, :card=>{:name=>"BananaBread"}, :view=>'new'
      assert_response :success, "response should succeed"
      assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
    end

    describe "#read" do
      it "works for basic request" do
        get :read, {:id=>'Sample_Basic'}
        response.body.match(/\<body[^>]*\>/im).should be_true
        # have_selector broke in commit 8d3bf2380eb8197410e962304c5e640fced684b9, presumably because of a gem (like capybara?)
        #response.should have_selector('body')
        assert_response :success
        'Sample Basic'.should == assigns['card'].name
      end

      it "handles nonexistent card" do
        get :read, {:id=>'Sample_Fako'}
        assert_response :success
      end

      it "handles nonexistent card without create permissions" do
        login_as :anonymous
        get :read, {:id=>'Sample_Fako'}
        assert_response 404
      end

      #it "invokes before_read hook" do
      #  Wagn::Hook.should_receive(:call).with(:before_read, "*all", instance_of(CardController))
      #  get :read, {:id=>'Sample_Basic'}
      #end
    end


    describe "#update" do
      it "works" do
        xhr :post, :update, { :id=>"~#{@simple_card.id}",
          :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id}
        assert_response :success, "edited card"
        assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
      end
    end

    it "new without typecode" do
      post :read, :view=>'new'
      assert_response :success, "response should succeed"
      assert_equal Card::BasicID, assigns['card'].type_id, "@card type should == Basic"
    end

    it "new with typecode" do
      get :read, :card => {:type=>'Date'}, :view=>'new'
      assert_response :success, "response should succeed"
      assert_equal Card::DateID, assigns['card'].type_id, "@card type should == Date"
    end

    it "delete" do
      c = Card.create( :name=>"Boo", :content=>"booya")
      delete :delete, :id=>"~#{c.id}"
      assert_response :redirect
      Card["Boo"].should == nil
    end

    it "should watch" do
      login_as('joe_user')
      post :watch, :id=>"Home", :toggle=>'on'
      assert c=Card["Home+*watchers"]
      c.content.should == "[[Joe User]]"

      post :watch, :id=>"Home", :toggle=>'off'
      assert c=Card["Home+*watchers"]
      c.content.should == ''
    end


    it "rename without update references should work" do
      Account.as 'joe_user'
      f = Card.create! :type=>"Cardtype", :name=>"Apple"
      xhr :post, :update, :id => "~#{f.id}", :card => {
        :name => "Newt",
        :update_referencers => "false",
      }
      assigns['card'].errors.empty?.should_not be_nil
      assert_response :success
      Card["Newt"].should_not be_nil
    end

    it "update typecode" do
      Account.as 'joe_user'
      xhr :post, :update, :id=>"~#{@simple_card.id}", :card=>{ :type=>"Date" }
      assert_response :success, "changed card type"
      Card['Sample Basic'].typecode.should == :date
    end


    #  what's happening with this test is that when changing from Basic to CardtypeA it is
    #  stripping the html when the test doesn't think it should.  this could be a bug, but it
    #  seems less urgent that a lot of the other bugs on the list, so I'm leaving this test out
    #  for now.
    #
    #  it "should test_update_cardtype_no_stripping" do
    #    Account.as 'joe_user'
    #    post :update, {:id=>@simple_card.id, :card=>{ :type=>"CardtypeA",:content=>"<br/>" } }
    #    #assert_equal "boo", assigns['card'].content
    #    assert_equal "<br/>", assigns['card'].content
    #    assert_response :success, "changed card type"
    #    assert_equal :cardtype_a", Card['Sample Basic'].typecode
    #  end
    #
  end
end

describe CardController, "test/integration card action tests" do

  #include LocationHelper

  before do
    login_as 'joe_user'
  end

  # Has Test
  # ---------
  # card/delete
  # card/create
  # connection/create
  # card/comment
  #
  # FIXME: Needs Test
  # -----------
  # card/rollback
  # card/save_draft
  # connection/delete ??

  it "should test_comment" do
    Account.as_bot  do
      Card.create :name=>'A+*self+*comment', :type=>'Pointer', :content=>'[[Anyone]]'
    end
    post :comment, :id=>"A", :card => { :comment=>"how come" }
    assert_response :success
  end

  it "should test_create_role_card" do
    login_as 'joe_admin'
    post :create, :card=>{:content=>"test", :type=>'Role', :name=>"Editor"}
    assert_response 302

    assert Card['Editor'].type_id == Card::RoleID
  end

  it "should test_create_cardtype_card" do
    Account.as_bot do
      post :create, 'card'=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor2"}
    end
    assert_response 302
    assert Card['Editor2'].typecode == :cardtype
  end

  it "should test_create" do
    Account.as_bot {
     post :create, :card=>{
      :type=>'Basic',
      :name=>"Editor",
      :content=>"testcontent2"
    }}
    assert_response 302
    assert_equal "testcontent2", Card["Editor"].content
  end

  it "should test_newcard_shows_edit_instructions" do
    given_card( {:type=>'cardtype', :name=>"YFoo", :content => ""} )
    given_card( {:name=>"YFoo+*type+*edit help", :content => "instruct-me"} )
    get :read, :view=>'new', :card => {:type=>'YFoo'}
    assert_tag :tag=>'div', :attributes=>{ :class=>"instruction" },  :content=>/instruct-me/
  end

  it "should test_newcard_works_with_fuzzy_renamed_cardtype" do
    given_card({:typecode=>:cardtype, :name=>"ZFoo", :content => ""})
    Account.as(:joe_user) do
      Card["ZFoo"].update_attributes! :name=>"ZFooRenamed", :update_referencers=>true
    end

    get :read, :view=>'new', :card => { :type=>'z_foo_renamed' }
    assert_response :success
  end

  it "should test_newcard_gives_reasonable_error_for_invalid_cardtype" do
    Account.as_bot do
      get :read, :vew=>'new', :card => { :type=>'bananamorph' }  
      assert_response 422
      assert_tag :tag=>'div', :attributes=>{:class=>/errors-view/}, :content=>/not a known type/
    end
  end

  it "should test_should_create_account_from_scratch" do
    login_as 'joe_admin'
    assert_difference ActionMailer::Base.deliveries, :size do
      post :create_account, :id=>'a', :user=>{:email=>'foo@bar.com'}
      assert_response :redirect  # this now redirects, and I think that is correct
    end
    email = ActionMailer::Base.deliveries[-1]
    # emails should be 'from' inviting user
    #assert_equal Account.user.email, email.from[0]
    #assert_equal 'active', User.find_by_email('new@user.com').status
    #assert_equal 'active', User.find_by_email('new@user.com').status
  end

  it "should test_update_user_account_email" do
    post :update_account, :id=>"Joe User".to_name.key, :account => { :email => 'joe@user.co.uk' }
    assert User.where(:card_id=>Card['joe_user'].id).first.email == 'joe@user.co.uk'
  end

  it "should test_user_cant_block_self" do
    post :update_account, :id=>"Joe User".to_name.key, :account => { :blocked => '1' }
    assert !User.where(:card_id=>Card['joe_user'].id).first.blocked?
  end

  private
  def given_card( *card_args )
    Account.as_bot do
      Card.create *card_args
    end
  end


end


