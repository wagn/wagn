require File.dirname(__FILE__) + '/../spec_helper'

describe CardController, "captcha_required?" do
  it "is false for joe user" do
    login_as :joe_user      
    @controller.send(:captcha_required?).should be_false
  end                                       
    
  context "for anonymous" do
    it "is true when global setting is true" do
      Card.create! :name=>"*captcha", :content=>"yes"
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when global setting is off" do
      Card.create! :name=>"*captcha", :content=>"no"
      @controller.send(:captcha_required?).should be_false
    end
    
    it "is true when type card setting is on and global setting is off" do
      User.as(:wagbot) do
        c=Card["Book"];c.permit(:create, Role[:anon]);c.save! 
        Card.create! :name=>"*captcha", :content=>"no"
        Card.create :name=>"Book+*captcha", :content => "yes"  
      end
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when type card setting is off and global setting is on" do
      User.as(:wagbot) do 
        c=Card["Book"];c.permit(:create, Role[:anon]);c.save! 
        Card.create! :name=>"*captcha", :content=>"yes"
        Card.create :name=>"Book+*captcha", :content => "no"  
      end
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_false
    end
  end
end  

describe CardController, "with captcha enabled requires captcha on" do
  before do
    User.as(:wagbot) do
      Card.create! :name=>"*captcha", :content=>"yes"
      #FIXME it would be nice if there were a simpler idiom for this     
      c = Card['Basic']
      c.permit(:create,Role[:anon])
      c.save!       
      a = Card['A']
      a.permit(:delete,Role[:anon])
      a.permit(:edit, Role[:anon])
      a.save!
    end
  end
  
  def require_captcha!
    @controller.should_receive(:verify_recaptcha).and_return(false)
  end
    
  it "create" do
    require_captcha!
    post :create, :card=>{:name=>"TestA", :content=>"TestC"}  
    Card["TestA"].should be_nil
  end
      
  it "remove" do
    require_captcha!
    post :remove, :id => "A"        
    Card["A"].should_not be_nil
  end
  
  it "update" do    
    require_captcha!
    post :update, :id=>"A", :card=>{:name=>"Booker"}
    Card["A"].should_not be_nil
  end
  
  it "quick_update" do
    require_captcha!
    post :quick_update, :id=>"A", :card=>{:type=>"Image"}
    Card["A"].type.should == 'Basic'
  end    
  
  it "comment" do
    require_captcha!
    post :comment, :id=>"A", :card=>{:content=>"Yeah"}
    Card["A"].content.should_not =~ /Yeah/
  end
  
  
  
end