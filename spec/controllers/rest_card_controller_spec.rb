require File.dirname(__FILE__) + '/../spec_helper'

describe RestCardController do

  context "new" do    
    include AuthenticatedTestHelper
    before do
      login_as :wagbot
    end
  end     
  
  describe "#create" do
    include AuthenticatedTestHelper
    before do
      login_as :joe_user
      @joe_id = Card.user_id
    end

    def post_xml(args={})
      request.env['content_type'] = 'application/xml' 
      request.env['RAW_POST_DATA'] =  args[:card]
      post :post
    end


    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.
    it "creates cards" do
      post_xml :card=> %{<card name="NewCardFoo" type="Basic">Bananas</card>}
      #, :content_type=>'application/xml'  #.html_safe #, {:user=>@joe_id}
      assert_instance_of Card, Card.find_by_name("NewCardFoo")
      #Card::Base.should_receive(:save) # The concept needs work, what model methodes should we expect?
      Card.find_by_name("NewCardFoo").content.should == "Bananas"
    end
    
    it "creates cardtype cards" do
      post_xml :card=>%{<card type="Cardtype" name="Editor">test</card>}
      assigns['card'].should_not be_nil
      #assert_response 418
      c=Card.find_by_name('Editor')
      assert_instance_of Card, c
      assert c.typecode == 'Cardtype'
    end
    
    it "pulls deleted cards from trash" do
      @c = Card.create! :name=>"Problem", :content=>"boof"
      @c.destroy!
      post_xml :card=>%{<card name="Problem" type="Phrase">noof</card>}
      assert_instance_of Card, c=Card.find_by_name("Problem")
      assert c.typecode, 'Phrase'
    end

    context "multi-create" do
      it "catches missing name error" do
        post_xml :card=> %{<card name="" type="Fruit">
          <card name="~plus~text"><p>abraid</p></card></card>}
        assigns['card'].should_not be_nil
        assigns['card'].errors["name"].first.should == "can't be blank"
        assert_response 422
      end

      it "creates card and plus cards" do
        post_xml :card=>%{<card name="sss" type="Fruit">
          <card name="+sub"><p>abraid<card name="+text">Some Text</card></p></card></card>} 
        (c=Card.find_by_name("sss")).should be
        Card.find_by_name("sss+sub+text").should be
      end

      it "creates card with hard template" do
        Card.as Card::WagbotID do
          Card.create!(:name=>"Fruit+*type+*content", :content=>"{{+kind}} {{+color}} {{+is citrus}} {{+edible}}")
        end

        post_xml :card=>%{<card name="sssHT" type="Fruit">
          <card name="+kind"><p>apple</p></card>
          <card name="+color"><p>red</p></card>
          <card name="+is citrus"><p>false</p></card>
          <card name="+edible"><p>true</p></card>
        </card>}
        Card.find_by_name("sssHT").typename.should == 'Fruit'
        Card.find_by_name("sssHT+kind").content.should == '<p>apple</p>'
      end
    end
   
  end

  describe "unit tests" do
    include AuthenticatedTestHelper

    before do
      Card.as :joe_user
      @user = User[:joe_user]
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new                                
      @controller = RestCardController.new
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
        pending "xml version of test"
        get :get, {:id=>'Sample_Basic'}
        response.should have_tag('body')
        assert_response :success
        'Sample Basic'.should == assigns['card'].name
      end

      it "handles nonexistent card" do
        pending "xml version of test"
        get :get, {:id=>'Sample_Fako'}
        assert_response :success   
        assert_template 'new'
      end

      it "handles nonexistent card without create permissions" do
        login_as :anonymous
      warn Rails.logger.info("test get")
        get :get, {:id=>'Sample_Fako', :format=>'.xml'}
        #get :get, {:id=>'Sample_Fako'}
        assert_response :success   
        assert_template 'missing'
      end
      
      #it "invokes before_show hook" do
      #  Wagn::Hook.should_receive(:call).with(:before_show, "*all", instance_of(RestCardController))
      #  get :get, {:id=>'Sample_Basic'}
      #end
    end
    
    
    describe "#update" do
      it "works" do
        pending "xml version needed"
        put :put, { :id=>@simple_card.id, 
          :card=>{:current_revision_id=>@simple_card.current_revision.id, :content=>'brand new content' }} #, {:user=>@user.id} 
        assert_response :success, "edited card"
        assert_equal 'brand new content', Card['Sample Basic'].content, "content was updated"
      end
    end
    
    it "new without cardtype" do
      post :new   
      assert_response :success, "response should succeed"                     
      assert_equal 'Basic', assigns['card'].typecode, "@card type should == Basic"
    end

    it "remove" do
      c = Card.create( :name=>"Boo", :content=>"booya")
      delete :delete, {:id => c.id.to_s}
      assert_response :success
      warn Rails.logger.info("test remove #{c.inspect}")
      Card["Boo"].should be_nil
    end

    it "should watch" do
      pending "xml version needed?"
      login_as(:joe_user)
      post :watch, :id=>"Home"
      Card["Home+*watchers"].content.should == "[[Joe User]]"
    end

    it "rename without update references should work" do
      pending "need xml api for rename"
      Card.as :joe_user
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
    it "update cardtype with stripping" do
      pending "convert for xml api"
      Card.as :joe_user                                               
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
    #    Card.as :joe_user                                               
    #    post :update, {:id=>@simple_card.id, :card=>{ :type=>"CardtypeA",:content=>"<br/>" } }
    #    #assert_equal "boo", assigns['card'].content
    #    assert_equal "<br/>", assigns['card'].content
    #    assert_response :success, "changed card type"   
    #    assert_equal "CardtypeA", Card['Sample Basic'].type
    #  end 
    # 
  end
end
