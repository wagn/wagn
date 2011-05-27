require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Flexmail do
  describe "#email_config_cardnames" do
    it "handles relative names" do
      User.as :wagbot do
        Card::Pointer.create! :name=>'emailtest+*right+*send', :content=>'[[_left+email_config]]'
        trigger_card = Card.new(:name=>'Huckleberry+emailtest')
        Flexmail.email_config_cardnames(trigger_card).first.should=='emailtest+*right+email_config'
      end
    end
  end
  
  describe ".configs_for" do
    before do
      User.current_user = :wagbot
      Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      Card.create! :name => "mailconfig+*from", :content => "from@user.com"
      Card.create! :name => "mailconfig+*subject", :content => "Subject of the mail"
      Card.create! :name => "emailtest+*right+*send", :content => "[[mailconfig]]"
    end
    
    it "returns empty list for card with no configs" do
      Flexmail.configs_for( Card.new( :name => "random" )).should == []
    end
    
    it "takes Pointer value for extended_list fields" do
      Card::Pointer.create! :name => "mailconfig+*cc", :content => "[[mailconfig+*to]]"
      c = Card.new(:name=>'Passion Fruit+emailtest')
      Flexmail.configs_for(c)[0][:cc].should == 'joe@user.com'
    end
    
    it "handles *email cards" do
      User.as(:wagbot) do
        Card::Pointer.create! :name => "mailconfig+*cc", :content => "[[Joe User+*email]]"
        Card::Search.create! :name => "mailconfig+*bcc", :content => '{"name":"Joe Admin","append":"*email"}'
      end
      User.as(:joe_user) do
        c = Card.new(:name=>'Kiwi+emailtest')
        conf = Flexmail.configs_for(c)[0]
        conf[:cc].should == 'joe@user.com'
        conf[:bcc].should == 'joe@admin.com'
      end
    end        
    
    it "returns list with correct hash for card with configs" do
      Card.create! :name => "mailconfig+*message", :content => "It's true that {{_left+story|naked}}"
      c = Card.create :name=>'Banana+story', :content=>"I was born a poor black seed"
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      Flexmail.configs_for(c).should == [{
        :to => "joe@user.com",
        :from => "from@user.com",
        :bcc => "",
        :cc => "",
        :subject => "Subject of the mail",
        :message => "It's true that I was born a poor black seed",
        :attach => ""
      }]
    end
  end

  describe "complex configs for" do
    before do
      class ActionView::Base
        def params
          if @controller
            @controller.params
          else
            {}
          end
        end
      end
      
      User.as :wagbot
      Card::Phrase.create!  :name => 'Bobs addy', :content=>'bob@bob.com'
      Card::Phrase.create!  :name => 'default subject', :content=>'a very nutty thang'
      Card::Search.create!  :name => "mailconfig+*to", :content => %{ {"key":"bob_addy"} }
      Card::Search.create!  :name => "mailconfig+*from", :content => %{ {"left":"_left", "right":"email"} }
      Card::Search.create!  :name => "subject search+*right+*content", :content => %{{"referred_to_by":"_self+subject"}}
      Card.create!  :name => "mailconfig+*subject", :content => "{{+subject search|naked;item:naked}}"
      Card.create! :name => "mailconfig+*message", :content => "Triggered by {{_self|name}} and its wonderful content: {{_self|naked}}"
      Card.create! :name => "mailconfig+*attach", :type=>"Pointer", :content => "[[_self+attachment]]"
      c = Card::Cardtype.create! :name=>'Trigger'
      c.permit(:read,   Role[:auth]) 
      c.save!
      Card.create :name=>'Trigger+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
      Card.create! :name=>'Trigger+*type+*content', :content=>''
      Card::Pointer.create! :name => "Trigger+*type+*send", :content => "[[mailconfig]]"

      User.as :anon
    end
        
    it "returns list with correct hash for card with configs" do
      System.base_url = 'http://a.com'
      c = Card::Trigger.create :name => "Banana Trigger", :content => "data content [[A]]"
      c.multi_create( 
        '~plus~email'=>{:content=>'gary@gary.com'},
        '~plus~subject'=>{:type=>'Pointer', :content=>'[[default subject]]'},
        '~plus~attachment' => {:type=>'File', :content=>"notreally.txt" }
      )
      conf = Flexmail.configs_for(c).first
      
      conf[:to     ].should == "bob@bob.com"
      conf[:from   ].should == "gary@gary.com"
      conf[:bcc    ].should == ''
      conf[:cc     ].should == ''
      conf[:subject].should == "a very nutty thang"
      conf[:attach ].should == ['Banana Trigger+attachment']
      conf[:message].should == "Triggered by Banana Trigger and its wonderful content: data content " +
        '<a class="known-card" href="http://a.com/wagn/A">A</a>'
    end
  end

  describe "hooks for" do
    describe "untemplated card" do
      before do
        User.as :wagbot
        Card.create! :name => "emailtest+*right+*send", :type => "Pointer", :content => "[[mailconfig]]"
        Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      end
    
      it "calls to mailer on Card#create" do
        Mailer.should_receive(:deliver_flexmail).with(hash_including(:to=>"joe@user.com"))
        Card.create :name => "Banana+emailtest"
      end
      
      it "handles case of referring to self for content" do
        Card.create! :name => "Email", :type => "Cardtype"
        Card.create! :name => "Email+*type+*send", :type => "Pointer", :content => "[[mailconfig]]"
        Card.create! :name => "mailconfig+*message", :content => "this {{_self|naked}}"
        
        Rails.logger.level = ActiveSupport::BufferedLogger::Severity::DEBUG
        Mailer.should_receive(:deliver_flexmail).with(hash_including(:message=>"this had betta work"))
        Card.create!(:name => "ToYou", :type => "Email", :content => "had betta work")
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




