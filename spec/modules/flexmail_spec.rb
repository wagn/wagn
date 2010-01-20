require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flexmail do  
  describe ".configs_for" do
    before do
      User.as :wagbot
      Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      Card.create! :name => "mailconfig+*from", :content => "from@user.com"
      Card.create! :name => "mailconfig+*subject", :content => "Subject of the mail"
      Card.create! :name => "mailconfig+*message", :content => "This {{_self|naked}}"
      Card.create! :name => "emailtest+*right+*send", :content => "[[mailconfig]]"
    end
    
    it "returns empty list for card with no configs" do
      Flexmail.configs_for( Card.new( :name => "random" )).should == []
    end
    
    it "returns list with correct hash for card with configs" do
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      Flexmail.configs_for(c).should == [{
        :to => "joe@user.com",
        :from => "from@user.com",
        :bcc => "",
        :subject => "Subject of the mail",
        :message => "This data content"
      }]
    end
  end

  describe "hooks for" do
    describe "untemplated card" do
      before do
        User.as :wagbot
        Card.create! :name => "emailtest+*right+*send", :type => "Pointer", 
          :content => "[[mailconfig]]"
        Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      end
    
      it "calls to mailer on Card#create" do
        Mailer.should_receive(:deliver_flexmail).with(hash_including(:to=>"joe@user.com"))
        Card.create :name => "Banana+emailtest"
      end
    end
    
    describe "templated card" do
      before do
        User.as :wagbot
        Card.create! :name => "Book+*type+*send", :type => "Pointer", 
          :content => "[[mailconfig]]"
        Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      end
    
      it "doesn't call to mailer on Card#create" do
        Mailer.should_not_receive(:deliver_flexmail)
        Card.create :name => "Banana+emailtest"
      end
      
      it "calls to mailer on Card#multi_create" do
        Mailer.should_receive(:deliver_flexmail).with(hash_including(:to=>"joe@user.com"))
        c = Card.create :name => "Illiodity", :type=>"Book"
        c.multi_create( {"~author" => {"name" => "Bukowski" }})
      end
    end
  end

  # Note: this mailer method and the corresponding template are defined in the regular rails places
  # rather that the flexmail module.
  # They can/should be brought out to more modular space if/when modules support adding
  # view template (through adding directories, etc.)
  describe "Mailer#flexmail" do
    # to access things like 'create_account_url' include UrlWriter
    # include ActionController::UrlWriter  
    
    before(:all) do 
      @email = Mailer.deliver_flexmail({ 
        :to=>"joe@user.com", 
        :subject=>"boo-ya", 
        :message=>"Ipsum Daido Lorem" 
      })   
    end
    
    it "respects to:" do
      @email.should deliver_to("joe@user.com")
    end
    
    it "respects subject:" do
      @email.should have_subject(/boo-ya/)
    end
    
    it "respects content:" do
      @email.should have_text(/Ipsum Daido Lorem/)
    end
  end
end




