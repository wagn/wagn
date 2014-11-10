describe Card::Set::Type::EmailTemplate do
  def mailconfig args={}
    Card['a mail template'].email_config(args)
  end
  
  before do
    Card::Auth.current_id = Card::WagnBotID
    Card.create! :name => "a mail template", :type=>:email_template, :subcards=>{
      "+*to" => { :content => "joe@user.com" },
      "+*from" => { :content => "from@user.com" },
      "+*subject" => { :content => "Subject of the mail" },
      "+*html_message" => { :content => "[[B]]" }
    }
  end
  
  describe "mail view" do
    let(:rendered_mail) { Card.fetch("a mail template").format.render_mail }
   
    
    it "renders absolute urls" do
      Card::Env[:protocol] = 'http://'
      Card::Env[:host] = 'www.fake.com'
      expect(rendered_mail.body).to include('<a class="known-card" href="http://www.fake.com/B">B</a>')
    end
    
    # it "renders multipart mails" do
    # end
    
    it 'renders broken config' do
      Card.fetch("a mail template+*to").update_attributes(:content=>"invalid mail address")
    end
  end
  
  describe "#email_config" do
    it "returns correct hash with email configuration" do
      Card['a mail template+*html_message'].update_attributes! :content => "Nobody expects the Spanish Inquisition"
      expect(mailconfig).to eq({
        :to => "joe@user.com",
        :from => "from@user.com",
        :subject => "Subject of the mail",
        :html_message => Card::Mailer.layout("Nobody expects the Spanish Inquisition"),
      })
    end
    
    it "uses context card for email config" do
      Card['a mail template+*html_message'].update_attributes! :content => "Nobody expects {{_left+surprise|core}}"
      c = Card.create :name=>'Banana+surprise', :content=>"the Spanish Inquisition"
      c = Card.create :name => "Banana+emailtest", :content => "data content"
      expect( mailconfig( context: c ) ).to eq({
        :to => "joe@user.com",
        :from => "from@user.com",
        :subject => "Subject of the mail",
        :html_message => Card::Mailer.layout("Nobody expects the Spanish Inquisition"),
      })
    end
    
    it "takes Pointer value for address fields" do
       Card.create! :name => "a mail template+*cc", :content => "[[joe@user.com]]", :type=>'Pointer'
       expect(mailconfig[:cc]).to eq('joe@user.com')
     end
     
     it "handles *email cards" do
       Card::Auth.as_bot do
         Card.create! :name => "a mail template+*cc", :content => "[[Joe User+*email]]", :type=>'Pointer'
         Card.create! :name => "a mail template+*bcc", :content => '{"name":"Joe Admin","append":"*email"}', :type=>'Search'
       end
       conf = mailconfig
       expect(conf[:cc]).to eq('joe@user.com')
       expect(conf[:bcc]).to eq('joe@admin.com')
     end
     
     it 'creates multipart email if text and html given' do
       Card.create! :name => "a mail template+*text_message", :content => "Nobody expects the Spanish Inquisition"
       email = render_card :mail, {:name=>"a mail template"}, {}
       expect(email[:content_type].value).to include('multipart/alternative')
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
        Card.create! :name => "mailconfig+*html message", :content => "Triggered by {{_self|name}} and its wonderful content: {{_self|core}}"
        Card.create! :name => "mailconfig+*attach", :type=>"Pointer", :content => "[[_self+attachment]]"
        Card.create! :name=>'Trigger', :type=>'Cardtype'
        Card.create! :name=>'Trigger+*type+*create', :type=>'Pointer', :content=>'[[Anonymous]]'
       # Card.create! :name => "Trigger+*type+*send", :content => "[[mailconfig]]", :type=>'Pointer'
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
        conf = mailconfig( context: c )

        expect(conf[:to     ]).to eq("bob@bob.com")
        expect(conf[:from   ]).to eq("gary@gary.com")
        expect(conf[:bcc    ]).to eq(nil)
        expect(conf[:cc     ]).to eq(nil)
        expect(conf[:subject]).to eq("a very nutty thang")
#        conf[:attach ].should == ['Banana Trigger+attachment']
        expect(conf[:html_message]).to  include("Triggered by Banana Trigger and its wonderful content: data content " +
          '<a class="known-card" href="http://a.com/A">A</a>')
      end
    end
  end
end
