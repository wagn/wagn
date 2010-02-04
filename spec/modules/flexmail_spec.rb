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
        :cc => "",
        :subject => "Subject of the mail",
        :message => "This data content"
      }]
    end
  end

  describe "complex configs for" do
    before do
      User.as :wagbot
      Card::Phrase.create!  :name => 'Bobs addy', :content=>'bob@bob.com'
      Card::Pointer.create! :name => 'his addy', :content=>'[[bobs addy]]'
      Card::Search.create!  :name => "mailconfig+*to", :content => %{ {"key":"bob_addy"} }
      Card::Search.create!  :name => "mailconfig+*from", :content => %{ {"referred_to_by":"his_addy"} }
      Card::Search.create!  :name => "mailconfig+*subject", :content => "{{his addy+*link | naked; item:name}}"
      Card.create! :name => "mailconfig+*message", :content => "Oughta get fancier"
      Card.create! :name => "emailtest+*right+*send", :content => "[[mailconfig]]"
      c= Card['Basic']; c.permit(:create, Role[:anon]); c.save!
      User.as :anon
    end
        
    it "returns list with correct hash for card with configs" do
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      Flexmail.configs_for(c).should == [{
        :to => "bob@bob.com",
        :from => "bob@bob.com",
        :bcc => "",
        :cc => '',
        :subject => "Bobs addy",
        :message => "Oughta get fancier"
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




