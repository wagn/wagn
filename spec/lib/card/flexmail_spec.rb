# -*- encoding : utf-8 -*-

describe Card::Flexmail do
  describe "#email_config_cardnames" do
    it "handles relative names" do
      Card::Auth.as_bot do
        Card.create! :name=>'emailtest+*right+*send', :content=>'[[_left+email_config]]', :type=>'Pointer'
        trigger_card = Card.new(:name=>'Huckleberry+emailtest')
        Card::Flexmail.email_config_cardnames(trigger_card).first.should=='emailtest+*right+email_config'
      end
    end
  end

  describe ".configs_for" do
    before do
      Card::Auth.current_id = Card::WagnBotID
      Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      Card.create! :name => "mailconfig+*from", :content => "from@user.com"
      Card.create! :name => "mailconfig+*subject", :content => "Subject of the mail"
      Card.create! :name => "emailtest+*right+*send", :content => "[[mailconfig]]"
    end

    it "returns empty list for card with no configs" do
      Card::Flexmail.configs_for( Card.new( :name => "random" )).should == []
    end

    it "takes Pointer value for extended_list fields" do
      Card.create! :name => "mailconfig+*cc", :content => "[[mailconfig+*to]]", :type=>'Pointer'
      c = Card.new(:name=>'Passion Fruit+emailtest')
      Card::Flexmail.configs_for(c)[0][:cc].should == 'joe@user.com'
    end

    it "handles *email cards" do
      Card::Auth.as_bot do
        Card.create! :name => "mailconfig+*cc", :content => "[[Joe User+*email]]", :type=>'Pointer'
        Card.create! :name => "mailconfig+*bcc", :content => '{"name":"Joe Admin","append":"*email"}', :type=>'Search'
      end
      c = Card.new(:name=>'Kiwi+emailtest')
      conf = Card::Flexmail.configs_for(c)[0]
      conf[:cc].should == 'joe@user.com'
      conf[:bcc].should == 'joe@admin.com'
    end

    it "returns list with correct hash for card with configs" do
      Card.create! :name => "mailconfig+*message", :content => "It's true that {{_left+story|core}}"
      c = Card.create :name=>'Banana+story', :content=>"I was born a poor black seed"
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      Card::Flexmail.configs_for(c).should == [{
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

      Card::Auth.as_bot do
        Card.create!  :name => 'Bobs addy', :content=>'bob@bob.com', :type=>'Phrase'
        Card.create!  :name => 'default subject', :content=>'a very nutty thang', :type=>'Phrase'
        Card.create!  :name => "mailconfig+*to", :content => %{ {"key":"bob_addy"} }, :type=>'Search'
        Card.create!  :name => "mailconfig+*from", :content => %{ {"left":"_left", "right":"email"} }, :type=>'Search'
        Card.create!  :name => "subject search+*right+*structure", :content => %{{"referred_to_by":"_self+subject"}}, :type=>'Search'
        Card.create!  :name => "mailconfig+*subject", :content => "{{+subject search|core;item:core}}"
        Card.create! :name => "mailconfig+*message", :content => "Triggered by {{_self|name}} and its wonderful content: {{_self|core}}"
        Card.create! :name => "mailconfig+*attach", :type=>"Pointer", :content => "[[_self+attachment]]"
        Card.create! :name=>'Trigger', :type=>'Cardtype'
        Card.create :name=>'Trigger+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
        Card.create! :name=>'Trigger+*type+*structure', :content=>''
        Card.create! :name => "Trigger+*type+*send", :content => "[[mailconfig]]", :type=>'Pointer'
      end
    end

    it "returns list with correct hash for card with configs" do
      pending 'spec is breaking but flexmail is being refactored'
      Card::Auth.as_bot do
        Card::Env[:protocol] = 'http://'
        Card::Env[:host]     = 'a.com'
        
        #c = Card.new(:name => "Banana Trigger", :content => "data content [[A]]", :type=>'Trigger')
        #warn "boom: #{ Card::Flexmail.configs_for(c).inspect }"
        
        c = Card.create(
          :name    => "Banana Trigger",
          :content => "data content [[A]]",
          :type    => 'Trigger',
          :subcards=> {
            '+email'      => {:content=>'gary@gary.com'},
            '+subject'    => {:type=>'Pointer', :content=>'[[default subject]]'},
#            '+attachment' => {:type=>'File', :content=>"notreally.txt" }
          }
        )
        conf = Card::Flexmail.configs_for(c).first

        conf[:to     ].should == "bob@bob.com"
        conf[:from   ].should == "gary@gary.com"
        conf[:bcc    ].should == ''
        conf[:cc     ].should == ''
        conf[:subject].should == "a very nutty thang"
#        conf[:attach ].should == ['Banana Trigger+attachment']
        conf[:message].should == "Triggered by Banana Trigger and its wonderful content: data content " +
          '<a class="known-card" href="http://a.com/A">A</a>'
      end
    end
  end

  describe "hooks for" do
    describe "untemplated card" do
      before do
        Card::Auth.as_bot {
          Card.create! :name => "emailtest+*right+*send", :type => "Pointer", :content => "[[mailconfig]]"
          Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
        }
      end

      it "calls to mailer only on Card#create" do
        Card::Auth.as_bot do
          mock( Card::Mailer ).flexmail( hash_including :to=>"joe@user.com" ).times 1
          c =Card.create :name => "Banana+emailtest"
          c.update_attributes! :content => 'short lived'
          c.delete!
        end
        
      end
      

      it "handles case of referring to self for content" do
        Card::Auth.as_bot do
          Card.create! :name => "Email", :type => "Cardtype"
          Card.create! :name => "Email+*type+*send", :type => "Pointer", :content => "[[mailconfig]]"
          Card.create! :name => "mailconfig+*message", :content => "this {{_self|core}}"
        end

        Rails.logger.level = ActiveSupport::BufferedLogger::Severity::DEBUG
        mock(Card::Mailer).flexmail(hash_including(:message=>"this had betta work"))
        Card.create!(:name => "ToYou", :type => "Email", :content => "had betta work")
      end

    end

    describe "templated card" do
      before do
        Card::Auth.as_bot do
          Card.create! :name => "Book+*type+*send", :type => "Pointer",
            :content => "[[mailconfig]]"
          Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
        end
      end

      it "doesn't call to mailer on Card#create" do
        mock.dont_allow(Card::Mailer).flexmail
        Card.create :name => "Banana+emailtest"
      end

      it "calls to mailer on Card#create" do
        mock(Card::Mailer).flexmail(hash_including(:to=>"joe@user.com")).at_least(1)
        c = Card.create :name => "Illiodity", :type=>"Book"
        Card.update(c.id, :subcards=> {"~author" => {"name" => "Bukowski"}})
      end
    end
  end

  # Note: this mailer method and the corresponding template are defined in the regular rails places
  # rather that the flexmail module.
  # They can/should be brought out to more modular space if/when modules support adding
  # view template (through adding directories, etc.)
  describe Card::Mailer do
    # to access things like 'create_account_url' include UrlWriter
    # include ActionController::UrlWriter

    before(:all) do
      @email = Card::Mailer.flexmail({
        :to=>"joe@user.com",
        :subject=>"boo-ya",
        :message=>"Ipsum Daido Lorem"
      })
    end

    it "respects to:" do
      @email.to.first.should == "joe@user.com"
    end

    it "respects subject:" do
      @email.subject.should match /boo-ya/
    end

    it "respects content:" do
      @email.body.should match /Ipsum Daido Lorem/
    end
  end
end




