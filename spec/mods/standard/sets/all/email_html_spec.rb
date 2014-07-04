# -*- encoding : utf-8 -*-

describe Card::EmailHtmlFormat do
  def render_mailconfig args={}
    Card['mailconfig'].format(:format=>:email_html)._render_config(args)
  end
  
  it "should render full urls" do
    Card::Env[:protocol] = 'http://'
    Card::Env[:host] = 'www.fake.com'
    render_content('[[B]]', :format=>'email_html').should == '<a class="known-card" href="http://www.fake.com/B">B</a>'
  end
  
  describe "raw view" do
    it "renders missing included cards as blank" do
      render_content('{{strombooby}}', :format=>'email_html').should == ''
    end
  
    it "renders local variables" do
      rendered = render_content_with_args('{{_myvalue}}', {format: 'email_html'}, {locals: { myvalue: "test" }} )
      expect( rendered ).to eq( 'test' )
    end
  
    it "renders erb" do
      rendered = render_content('<%= "Nobody expects the Spanish Inquisition!" %>', format: 'email_html' )
      expect( rendered ).to eq( "Nobody expects the Spanish Inquisition!" )
    end
  
    it "renders erb with locals" do
      rendered = render_content_with_args('<%= @text %>', {format: 'email_html'}, {locals: {text: "Nobody expects the Spanish Inquisition!"}} )
      expect( rendered ).to eq( "Nobody expects the Spanish Inquisition!" )
    end
  end
  
  describe "config view" do
    before do
      Card::Auth.current_id = Card::WagnBotID
      Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
      Card.create! :name => "mailconfig+*from", :content => "from@user.com"
      Card.create! :name => "mailconfig+*subject", :content => "Subject of the mail"
      Card.create! :name => "emailtest+*right+*send", :content => "[[mailconfig]]"
    end

    it "returns correct hash with email configuration" do
      Card.create! :name => "mailconfig+*message", :content => "Nobody expects the Spanish Inquisition"
      expect(render_mailconfig).to eq({
        :to => "joe@user.com",
        :from => "from@user.com",
        :bcc => "",
        :cc => "",
        :subject => "Subject of the mail",
        :body => "Nobody expects the Spanish Inquisition",
        :content_type => "text/html"
      })
    end
    
    it "uses context card for email config" do
      Card.create! :name => "mailconfig+*message", :content => "Nobody expects {{_left+surprise|core}}"
      c = Card.create :name=>'Banana+surprise', :content=>"the Spanish Inquisition"
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      expect( render_mailconfig( context: c ) ).to eq({
        :to => "joe@user.com",
        :from => "from@user.com",
        :bcc => "",
        :cc => "",
        :subject => "Subject of the mail",
        :body => "Nobody expects the Spanish Inquisition",
        :content_type => "text/html"
      })
    end
    
    it "takes Pointer value for config fields" do
       Card.create! :name => "mailconfig+*cc", :content => "[[mailconfig+*to]]", :type=>'Pointer'
       expect(render_mailconfig[:cc]).to eq('joe@user.com')
     end
     
     it "handles *email cards" do
       Card::Auth.as_bot do
         Card.create! :name => "mailconfig+*cc", :content => "[[Joe User+*email]]", :type=>'Pointer'
         Card.create! :name => "mailconfig+*bcc", :content => '{"name":"Joe Admin","append":"*email"}', :type=>'Search'
       end
       conf = render_mailconfig
       conf[:cc].should == 'joe@user.com'
       conf[:bcc].should == 'joe@admin.com'
     end
  end

  describe "complex config view" do
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

    it "returns correct hash with email configuration" do
      Card::Auth.as_bot do
        Card::Env[:protocol] = 'http://'
        Card::Env[:host]     = 'a.com'

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
        byebug
        conf = render_mailconfig( context: c )

        conf[:to     ].should == "bob@bob.com"
        conf[:from   ].should == "gary@gary.com"
        conf[:bcc    ].should == ''
        conf[:cc     ].should == ''
        conf[:subject].should == "a very nutty thang"
#        conf[:attach ].should == ['Banana Trigger+attachment']
        expect(conf[:body]).to  include("Triggered by Banana Trigger and its wonderful content: data content " +
          '<a class="known-card" href="http://a.com/A">A</a>')
      end
    end
  end


  # describe "hooks for" do
  #   describe "untemplated card" do
  #     before do
  #       Card::Auth.as_bot {
  #         Card.create! :name => "emailtest+*right+*send", :type => "Pointer", :content => "[[mailconfig]]"
  #         Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
  #       }
  #     end
  #
  #     it "calls to mailer only on Card#create" do
  #       Card::Auth.as_bot do
  #         mock( Card::Mailer ).flexmail( hash_including :to=>"joe@user.com" ).times 1
  #         c =Card.create :name => "Banana+emailtest"
  #         c.update_attributes! :content => 'short lived'
  #         c.delete!
  #       end
  #
  #     end
  #
  #
  #     it "handles case of referring to self for content" do
  #       Card::Auth.as_bot do
  #         Card.create! :name => "Email", :type => "Cardtype"
  #         Card.create! :name => "Email+*type+*send", :type => "Pointer", :content => "[[mailconfig]]"
  #         Card.create! :name => "mailconfig+*message", :content => "this {{_self|core}}"
  #       end
  #
  #       Rails.logger.level = ActiveSupport::BufferedLogger::Severity::DEBUG
  #       mock(Card::Mailer).flexmail(hash_including(:message=>"this had betta work"))
  #       Card.create!(:name => "ToYou", :type => "Email", :content => "had betta work")
  #     end
  #
  #   end
  #
  #   describe "templated card" do
  #     before do
  #       Card::Auth.as_bot do
  #         Card.create! :name => "Book+*type+*send", :type => "Pointer",
  #           :content => "[[mailconfig]]"
  #         Card.create! :name => "mailconfig+*to", :content => "joe@user.com"
  #       end
  #     end
  #
  #     it "doesn't call to mailer on Card#create" do
  #       mock.dont_allow(Card::Mailer).flexmail
  #       Card.create :name => "Banana+emailtest"
  #     end
  #
  #     it "calls to mailer on Card#create" do
  #       mock(Card::Mailer).flexmail(hash_including(:to=>"joe@user.com")).at_least(1)
  #       c = Card.create :name => "Illiodity", :type=>"Book"
  #       Card.update(c.id, :subcards=> {"~author" => {"name" => "Bukowski"}})
  #     end
  #   end
  # end
end
