require File.dirname(__FILE__) + '/../spec_helper'

module CaptchaExampleGroupMethods
  def require_captcha_on(action, params)
    ENV['RECAPTCHA_PUBLIC_KEY'] = 'not nil'
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
  before do
    User.as :wagbot do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      Card.create :name=>'Book+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
#      c=Card["Book"];c.permit(:create, Role[:anon]);c.save! 
      Card.create :name=>"Book+*type+*captcha", :content => "1"  
    end
  end
  
  it "is false for joe user" do
    login_as :joe_user      
    @controller.send(:captcha_required?).should be_false
  end                                       

  context "for anonymous" do
    it "is true when global setting is true" do
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when global setting is off" do
      User.as(:wagbot) { c= Card['*all+*captcha']; c.content='0'; c.save! }
      @controller.send(:captcha_required?).should be_false
    end

    it "is true when type card setting is on and global setting is off" do
      User.as(:wagbot) { c= Card['*all+*captcha']; c.content='0'; c.save! }
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_true
    end

    it "is false when type card setting is off and global setting is on" do
      User.as :wagbot do
        c= Card['Book+*type+*captcha']; c.content='0'; c.save!
      end
      get :new, :type=>"Book"
      @controller.send(:captcha_required?).should be_false
    end
  end
end  

describe CardController, "with captcha enabled requires captcha on" do   
  before do
    User.as(:wagbot) do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      #FIXME it would be nice if there were a simpler idiom for this     
      Card.create :name=>'Basic+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
      %w{ update delete }.each do |op| 
        Card.create :name=>"A+*self+*#{op}", :type=>'Pointer', :content=>'[[Anyone]]'
      end
    end
  end

  require_captcha_on :create, :card=>{:name=>"TestA", :content=>"TestC"} 
  require_captcha_on :remove, :id => "A"        
  require_captcha_on :update, :id=>"A", :card=>{:name=>"Booker"}
  require_captcha_on :quick_update, :id=>"A", :card=>{:type=>"Image"}
  require_captcha_on :comment, :id=>"A", :card=>{:content=>"Yeah"}
end

describe AccountController, "with captcha enabled" do    
  before do
    User.as(:wagbot) do
      Card["*all+*captcha"].update_attributes! :content=>"1"
      #FIXME it would be nice if there were a simpler idiom for this     
    end
  end

  User.as :anon do
    require_captcha_on( 
      :signup, 
      :card => { :name => "Bob", :type=>"Account Request" },
      :user => { :email => "bob@user.com" }
    )
  end

end