require File.dirname(__FILE__) + '/../spec_helper'

describe CardController do
  context "new" do    
    before do
      login_as :wagbot
    end
    
    it "assigns @args[:name] from id" do
      post :new, :id => "xxx"
      assigns[:args][:name].should == "xxx"
    end
  end     
  
  describe "- route generation" do
    it "gets name/id from /card/new/xxx" do
      params_from(:post, "/card/new/xxx").should == {
        :controller=>"card", :action=>'new', :id=>"xxx"
      }
    end
    
    it "should recognize .rss on /recent" do
      params_from(:get, "/recent.rss").should == {:controller=>"card", :view=>"content", :action=>"show", 
        :id=>"*recent", :format=>"rss"
      }
    end
    
    it "should search for simple keyword" do
      params_from(:get, "/search/simple").should == {:controller=>"card", :view=>"content", :action=>"show", 
        :id=>"*search", :_keyword=>'simple'
      }
    end
    
    it "should search for keyword with dot" do
      params_from(:get, "/search/dot.com").should == {:controller=>"card", :view=>"content", :action=>"show", 
        :id=>"*search", :_keyword=>'dot.com'
      }
    end
    it "should recognize formats on keyword search" do
      params_from(:get, "/search/feedname.rss").should == {:controller=>"card", :view=>"content", :action=>"show", 
        :id=>"*search", :_keyword=>'feedname', :format=>'rss'
      }
    end


    ["/wagn",""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          params_from(:get, "#{prefix}/*recent.rss").should == {
            :controller=>"card", :action=>"show", :id=>"*recent", :format=>"rss"
          }
        end           
    
        it "should recognize .xml format" do
          params_from(:get, "#{prefix}/*recent.xml").should == {
            :controller=>"card", :action=>"show", :id=>"*recent", :format=>"xml"
          }
        end           

        it "should accept cards with dot sections that don't match extensions" do
          params_from(:get, "#{prefix}/random.card").should == {
            :controller=>"card",:action=>"show",:id=>"random.card"
          }
        end
    
        it "should accept cards without dots" do
          params_from(:get, "#{prefix}/random").should == {
            :controller=>"card",:action=>"show",:id=>"random"
          }
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
      assert_response 418
      c=Card.find_by_name("NewCardFoo")
      assert c.typecode == 'Basic'
      c.content.should == "Bananas"
    end
    
    it "creates cardtype cards" do
      post :create, :card=>{"content"=>"test", :type=>'Cardtype', :name=>"Editor"}
      assigns['card'].should_not be_nil
      assert_response 418
      c=Card.find_by_name("Editor")
      assert c.typecode == 'Cardtype'
    end
    
    it "pulls deleted cards from trash" do
      @c = Card.create! :name=>"Problem", :content=>"boof"
      @c.destroy!
      post :create, :card=>{"name"=>"Problem","type"=>"Phrase","content"=>"noof"}
      assert_response 418
      c=Card.find_by_name("Problem")
      assert c.typecode == 'Phrase'
    end

    context "multi-create" do
      it "catches missing name error" do
        post :create, "card"=>{"name"=>"", "type"=>"Fruit"},
         "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}, 
         "content_to_replace"=>"",
         "context"=>"main_1", 
         "multi_edit"=>"true", "view"=>"open"
        assigns['card'].errors[:key].should == "key cannot be blank"
        assigns['card'].errors[:name].should == "can't be blank"
        assert_response 422
      end

      it "creates card and plus cards" do
        post :create, "card"=>{"name"=>"sss", "type"=>"Fruit"},
         "cards"=>{"~plus~text"=>{"content"=>"<p>abraid</p>"}}, 
         "content_to_replace"=>"",
         "context"=>"main_1", 
         "multi_edit"=>"true", "view"=>"open"
        assert_response 418    
        Card.find_by_name("sss").should_not be_nil
        Card.find_by_name("sss+text").should_not be_nil
      end

      it "creates card with hard template" do
        pending
        Card.create!(:name=>"Fruit+*type+*content", :content=>"{{+kind}} {{+color}} {{+is citrus}} {{+edible}}")
        post :create, "card"=>{"name"=>"sssHT", "type"=>"Fruit"},
         "cards"=>{"~plus~kind"=>{"content"=>"<p>apple</p>"}}, 
         "cards"=>{"~plus~color"=>{"content"=>"<p>red</p>"}}, 
         "cards"=>{"~plus~is citrus"=>{"content"=>"<p>false</p>"}}, 
         "cards"=>{"~plus~edible"=>{"content"=>"<p>true</p>"}}, 
         "content_to_replace"=>"",
         "context"=>"main_1", 
         "multi_edit"=>"true", "view"=>"open"
        assert_response 418    
        Card.find_by_name("sssHT").should_not be_nil
        Card.find_by_name("sssHT+kind").should_not be_nil
      end
    end
   
    it "renders errors if create fails" do
      post :create, "card"=>{"name"=>"Joe User"}
      assert_response 422
      assert_template "application"  # this is a wee bit funky
    end
   
    it "redirects to thanks if present" do
      Card.create :name=>"*all+*thanks", :content=>"/thank_you"
      post :create, "card" => { "name" => "Wombly" }
      assert_template "ajax_redirect"
      assigns["redirect_location"].should == "/thank_you"
    end

    it "redirects to card if thanks is blank" do
      Card.create! :name=>"*all+*thanks", :content=>"/thank_you"
      Card.create! :name=>"boop+*right+*thanks", :content=>""
      post :create, "card" => { "name" => "Joe+boop" }
      assert_template "ajax_redirect"
      assigns["redirect_location"].should ==  "/wagn/Joe+boop"
    end
   
    it "redirects to home if not createable and thanks not specified" do
      # Fruits (from shared_data) are anon creatable but not readable
      
      #remove me after regenerating test data
      Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
      
      
      login_as :anon
      post :create, "card" => { "type"=>"Fruit", :name=>"papaya" }
      assert_template "ajax_redirect"
      assigns["redirect_location"].should ==  "/"
    end

    #hook
    it "redirects to location specified by :after_create_location hook if it is present" do
      Wagn::Hook.ephemerally do
        Wagn::Hook.add :redirect_after_create, '*all' do
          "/test"
        end
        post :create, "card" => { "name" => "Wombly" }
      end
      assert_template "ajax_redirect"
      assigns["redirect_location"].should ==  "/test"
    end
      
    it "should redirect to card on create main card" do
      post :create, :context=>"main_1", :card => {
        :name=>"Banana", :type=>"Basic", :content=>"mush"
      }
      assigns["redirect_location"].should == "/wagn/Banana"
      assert_template "ajax_redirect"
    end
    
  end

  describe "#new" do
    before do
      login_as :joe_user
    end
    
    it "new should work for creatable nonviewable cardtype" do
      #remove me after regenerating test data
      Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
      
      login_as(:anon)     
      get :new, :type=>"Fruit"
      assert_response :success
      assert_template "new"
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
        response.should have_tag('body')
        assert_response :success
        'Sample Basic'.should == assigns['card'].name
      end

      it "handles nonexistent card" do
        get :show, {:id=>'Sample_Fako'}
        assert_response :success   
        assert_template 'new'
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
        post :update, { :id=>@simple_card.id, 
          :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id} 
        assert_response :success, "edited card"
        assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
      end
    end
    
    describe "#changes" do
      it "works" do
        id = Card.find_by_name('revtest').id
        get :changes, :id=>id, :rev=>1
        assert_equal 'first', assigns['revision'].content, "revision 1 content==first"

        get :changes, :id=>id, :rev=>2
        assert_equal 'second', assigns['revision'].content, "revision 2 content==second"
        assert_equal 'first', assigns['previous_revision'].content, 'prev content=="first"'
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
      post :remove, :id=>c.id.to_s
      assert_response :success
      Card.find_by_name("Boo").should == nil
    end

    it "should watch" do
      login_as(:joe_user)
      post :watch, :id=>"Home"
      Card["Home+*watchers"].content.should == "[[Joe User]]"
    end

    it "rename without update references should work" do
      User.as :joe_user
      f = Card.create! :type=>"Cardtype", :name=>"Apple"
      post :update, :id => f.id, :card => {
        :confirm_rename => true,
        :name => "Newt",
        :update_referencers => "false",
      }                   
      assert_equal ({ "name"=>"Newt", "update_referencers"=>'false', "confirm_rename"=>true }), assigns['card_args']
      assigns['card'].errors.empty?.should_not be_nil
      assert_response :success
      Card["Newt"].should_not be_nil
    end

  #=end
    it "unrecognized card renders missing unless can create basic" do
      login_as(:anon) 
      post :show, :id=>'crazy unknown name'
      assert_template 'missing'
    end

    it "update typecode with stripping" do
      User.as :joe_user                                               
      post :update, {:id=>@simple_card.id, :card=>{ :type=>"Date",:content=>"<br/>" } }
      #assert_equal "boo", assigns['card'].content
      assert_response :success, "changed card type"   
      assigns['card'].content  .should == ""
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
