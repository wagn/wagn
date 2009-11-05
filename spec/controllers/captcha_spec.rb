require File.dirname(__FILE__) + '/../spec_helper'

module CaptchaExampleGroupMethods
  def require_captcha_on(action, params)
    it action.to_s do
      require_captcha!
      post action, params    
      #yield if block_given?
    end
  end
end  

module CaptchaExampleMethods
  def require_captcha!  
    @controller.should_receive(:verify_captcha).and_return(false)
  end
end

Spec::Rails::Example::ControllerExampleGroup.extend CaptchaExampleGroupMethods
Spec::Rails::Example::ControllerExampleGroup.send(:include, CaptchaExampleMethods)

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

  require_captcha_on :create, :card=>{:name=>"TestA", :content=>"TestC"} 
  require_captcha_on :remove, :id => "A"        
  require_captcha_on :update, :id=>"A", :card=>{:name=>"Booker"}
  require_captcha_on :quick_update, :id=>"A", :card=>{:type=>"Image"}
  require_captcha_on :comment, :id=>"A", :card=>{:content=>"Yeah"}
end

describe AccountController, "with captcha enabled" do
  require_captcha_on( :signup, 
                      :card => 
                      { :name => "Bob", :type=>"InvitationRequest" },
                      :user => { :email => "bob@user.com" })

end