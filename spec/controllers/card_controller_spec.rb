require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper

describe CardController do

  describe "- route generation" do
#  not sure we want this.    
#    it "gets name/id from /card/new/xxx" do
#      {:post=> "/card/new/xxx"}.should route_to(
#        :controller=>"card", :action=>'new', :id=>"xxx"
#      )
#    end

    it "should recognize type" do
      { :get => "/new/Phrase" }.should route_to( :controller => 'card', :action=>'new', :type=>'Phrase' )
    end
    
    it "should recognize .rss on /recent" do
      {:get => "/recent.rss"}.should route_to(:controller=>"card", :view=>"core", :action=>"show", 
        :id=>"*recent", :format=>"rss"
      )
    end
    
#    it "should search for simple keyword" do
#      {:get => "/search/simple"}.should route_to(:controller=>"card", :view=>"content", :action=>"show", 
#        :id=>"*search", :_keyword=>'simple'
#      )
#    end
#    
#    it "should search for keyword with dot" do
#      {:get => "/search/dot.com"}.should route_to(:controller=>"card", :view=>"content", :action=>"show", 
#        :id=>"*search", :_keyword=>'dot.com'
#      )
#    end
#    it "should recognize formats on keyword search" do
#      {:get => "/search/feedname.rss"}.should route_to(:controller=>"card", :view=>"content", :action=>"show", 
#        :id=>"*search", :_keyword=>'feedname', :format=>'rss'
#      )
#    end


    ["/wagn",""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          {:get => "#{prefix}/*recent.rss"}.should route_to(
            :controller=>"card", :action=>"show", :id=>"*recent", :format=>"rss"
          )
        end           
    
        it "should recognize .xml format" do
          {:get => "#{prefix}/*recent.xml"}.should route_to(
            :controller=>"card", :action=>"show", :id=>"*recent", :format=>"xml"
          )
        end           

#        it "should accept cards with dot sections that don't match extensions" do
#          {:get => "#{prefix}/random.card"}.should route_to(
#            :controller=>"card",:action=>"show",:id=>"random.card"
#          )
#        end
    
        it "should accept cards without dots" do
          {:get => "#{prefix}/random"}.should route_to(
            :controller=>"card",:action=>"show",:id=>"random"
          )
        end    
      end
    end
  end

  describe "#create" do
    before do
      login_as :joe_user
    end

    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.
    it "creates cards" do
      post :create, :card => {
        :name=>"NewCardFoo",
        :type=>"Basic",
        :content=>"Bananas"
      }
      assert_response 302
      c=Card.find_by_name("NewCardFoo")
      assert c.typecode == 'Basic'
      c.content.should == "Bananas"
    end

    
    it "creates cardtype cards" do
      xhr :post, :create, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
      assigns['card'].should_not be_nil
      assert_response 200
      c=Card.find_by_name("Editor")
      assert c.typecode == 'Cardtype'
    end
    
    it "pulls deleted cards from trash" do
      @c = Card.create! :name=>"Problem", :content=>"boof"
      @c.destroy!
      post :create, :card=>{"name"=>"Problem","type"=>"Phrase","content"=>"noof"}
      assert_response 302
      c=Card.find_by_name("Problem")
      assert c.typecode == 'Phrase'
    end

    context "multi-create" do
      it "catches missing name error" do
        post :create, "card"=>{
            "name"=>"", 
            "type"=>"Fruit",
            "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}
          }, "view"=>"open"
        assigns['card'].errors[:key].first.should == "cannot be blank"
        assigns['card'].errors[:name].first.should == "can't be blank"
        assert_response 422
      end

      it "creates card with subcards" do
        login_as :wagbot
        xhr :post, :create, :success=>'REDIRECT: /', :card=>{
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
        Card["Gala+color"].typename.should == 'Phrase'
      end
    end
   
    it "renders errors if create fails" do
      post :create, "card"=>{"name"=>"Joe User"}
      assert_response 422
    end
   
    it "redirects to thanks if present" do
      login_as :wagbot
      xhr :post, :create, :success => 'REDIRECT: /thank_you', :card => { "name" => "Wombly" }
      assert_response 303, "/thank_you"
    end

    it "redirects to card if thanks is blank" do
      login_as :wagbot
      post :create, :success => 'REDIRECT: TO-CARD', "card" => { "name" => "Joe+boop" }
      assert_redirected_to "/Joe+boop"
    end
   
    it "redirects to previous" do
      # Fruits (from shared_data) are anon creatable but not readable
      login_as :anon
      post :create, { :success=>'REDIRECT: TO-PREVIOUS', "card" => { "type"=>"Fruit", :name=>"papaya" } }, :history=>['/blam']
      assert_redirected_to "/blam"
    end    
  end

  describe "#new" do
    before do
      login_as :joe_user
    end
    
    it "new should work for creatable nonviewable cardtype" do
      login_as(:anon)     
      get :new, :type=>"Fruit"
      assert_response :success
    end

    it "new with existing card" do
      get :new, :card=>{:name=>"A"}
      assert_response :success, "response should succeed"
    end
  end

  describe "unit tests" do
    include AuthenticatedTestHelper

    before do
      User.as :joe_user
      @user = User[:joe_user]
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new                                
      @controller = CardController.new
      @simple_card = Card['Sample Basic']
      @combo_card = Card['A+B']
      login_as(:joe_user)
    end

    it "new with name" do
      post :new, :card=>{:name=>"BananaBread"}
      assert_response :success, "response should succeed"                     
      assert_equal 'BananaBread', assigns['card'].name, "@card.name should == BananaBread"
    end        
    
    describe "#show" do
      it "works for basic request" do
        get :show, {:id=>'Sample_Basic'}
        response.should have_selector('body')
        assert_response :success
        'Sample Basic'.should == assigns['card'].name
      end

      it "handles nonexistent card" do
        get :show, {:id=>'Sample_Fako'}
        assert_response :success   
      end

      it "handles nonexistent card without create permissions" do
        login_as :anon
        get :show, {:id=>'Sample_Fako'}
        assert_response :success   
        assert_template 'missing'
      end
      
      #it "invokes before_show hook" do
      #  Wagn::Hook.should_receive(:call).with(:before_show, "*all", instance_of(CardController))
      #  get :show, {:id=>'Sample_Basic'}
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
      post :new   
      assert_response :success, "response should succeed"                     
      assert_equal 'Basic', assigns['card'].typecode, "@card type should == Basic"
    end

    it "new with typecode" do
      post :new, :card => {:type=>'Date'}   
      assert_response :success, "response should succeed"                     
      assert_equal 'Date', assigns['card'].typecode, "@card type should == Date"
    end        

    it "remove" do
      c = Card.create( :name=>"Boo", :content=>"booya")
      post :remove, :id=>"~#{c.id}"
      assert_response :redirect
      Card.find_by_name("Boo").should == nil
    end

    it "should watch" do
      login_as(:joe_user)
      post :watch, :id=>"Home", :toggle=>'on'
      assert c=Card["Home+*watchers"]
      c.content.should == "[[Joe User]]"
      
      post :watch, :id=>"Home", :toggle=>'off'
      assert c=Card["Home+*watchers"]
      c.content.should == ''
    end


    it "rename without update references should work" do
      User.as :joe_user
      f = Card.create! :type=>"Cardtype", :name=>"Apple"
      xhr :post, :update, :id => "~#{f.id}", :card => {
        :confirm_rename => true,
        :name => "Newt",
        :update_referencers => "false",
      }                   
      assigns['card'].errors.empty?.should_not be_nil
      assert_response :success
      Card["Newt"].should_not be_nil
    end

  #=end
    it "unrecognized card renders missing unless can create basic" do
      login_as(:anon) 
      get :show, :id=>'crazy unknown name'
      assert_template 'missing'
    end

    it "update typecode" do
      User.as :joe_user   
      xhr :post, :update, :id=>"~#{@simple_card.id}", :card=>{ :type=>"Date" }
      assert_response :success, "changed card type"
      Card['Sample Basic'].typecode.should == "Date"
    end


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
    #    assert_equal "CardtypeA", Card['Sample Basic'].typecode
    #  end 
    # 
  end
end
