# -*- encoding : utf-8 -*-

describe Card::Set::Type::Signup do
  before do
    Card::Auth.current_id = Card::AnonymousID
  end

  context "signup form form" do
    before do
      card = Card.new type_id: Card::SignupID
      @form = card.format.render_new
    end

    it "prompts to signup" do
      Card::Auth.as :anonymous do
        expect(@form.match(/Sign up/)).to be_truthy
      end
    end
  end

  context "signup (without approval)" do
    before do
      ActionMailer::Base.deliveries = [] # needed?

      Card::Auth.as_bot do
        Card.create! name: "User+*type+*create", content: "[[Anyone]]"
      end

      Card::Auth.current_id = Card::AnonymousID
      @signup = Card.create!(
        name: "Big Bad Wolf", type_id: Card::SignupID,
        "+*account" => { "+*email" => "wolf@wagn.org", "+*password" => "wolf" }
      )

      @account = @signup.account
      @token = @account.token
    end

    it "creates all the necessary cards" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@wagn.org")
      expect(@account.status).to eq("pending")
      expect(@account.salt).not_to eq("")
      expect(@account.password.length).to be > 10 # encrypted
      expect(@account.token).to be_present
    end

    it "sends email with an appropriate link" do
      @mail = ActionMailer::Base.deliveries.last
      body = @mail.parts[0].body.raw_source
      expect(body).to match(Card.global_setting(:title))
    end

    it "creates an authenticable token" do
      expect(@account.token).to eq(@token)
      expect(@account.validate_token!(@token)).to be_truthy
      expect(@account.errors).to be_empty
    end

    it "notifies someone" do
      expect(ActionMailer::Base.deliveries.map(&:to).sort).to(
        eq [["signups@wagn.org"], ["wolf@wagn.org"]]
      )
    end

    it "is activated by an update" do
      Card::Env.params[:token] = @token
      @signup = Card.fetch "big bad wolf"
      @signup.update_attributes({})
      # puts @signup.errors.full_messages * "\n"
      expect(@signup.errors).to be_empty
      expect(@signup.type_id).to eq(Card::UserID)
      expect(@account.status).to eq("active")
      expect(Card[@account.name].active?).to be_truthy
    end

    it "rejects expired token and creates new token" do
      @account.token_card.update_column :updated_at,
                                        8.days.ago.strftime("%F %T")
      @account.token_card.expire
      Card::Env.params[:token] = @token
      @signup = Card.fetch "big bad wolf"
      result = @signup.update_attributes!({})
      # successfully completes save
      expect(result).to eq(true)
      @account.reload
      # token gets updated
      expect(@account.token).not_to eq(@token)
      # user notified of expired token
      expect(Card::Env.success.message).to match(/expired/)
    end
  end

  context "signup (with approval)" do
    before do
      # NOTE: by default Anonymous does not have permission
      # to create User cards.
      Mail::TestMailer.deliveries.clear
      Card::Auth.current_id = Card::AnonymousID
      @signup = Card.create! name: "Big Bad Wolf",
                             type_id: Card::SignupID,
                             "+*account" => {
                               "+*email" => "wolf@wagn.org",
                               "+*password" => "wolf"
                             }
      @account = @signup.account
    end

    it "should create all the necessary cards, but no token" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@wagn.org")
      expect(@account.status).to eq("pending")
      expect(@account.salt).not_to eq("")
      expect(@account.password.length).to be > 10 # encrypted
    end

    it "should not create a token" do
      expect(@account.token).not_to be_present
    end

    it "sends signup alert email" do
      signup_alert = ActionMailer::Base.deliveries.last
      expect(signup_alert.to).to eq(["signups@wagn.org"])
      [0, 1].each do |part|
        body = signup_alert.body.parts[part].body.raw_source
        expect(body).to include(@signup.name)
        expect(body).to include("wolf@wagn.org")
      end
    end

    it "does not send verification email" do
      expect(Mail::TestMailer.deliveries[-2]).to be_nil
    end

    context "approval with token" do
      it "should create token" do
        Card::Env.params[:approve_with_token] = true
        Card::Auth.as "joe_admin"

        @signup = Card.fetch @signup.id
        @signup.save!
        expect(@signup.account.token).to be_present
      end
    end

    context "approval without token" do
      it "should create token" do
        Card::Env.params[:approve_without_token] = true
        Card::Auth.as "joe_admin"

        @signup = Card.fetch @signup.id
        @signup.save!
        expect(@signup.account.token).not_to be_present
        expect(@signup.type_id).to eq(Card::UserID)
        expect(@signup.account.status).to eq("active")
      end
    end
  end

  context "a welcome email card exists" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "welcome email",
                     type_id: Card::EmailTemplateID,
                     subcards: {
                       "+*subject" => "welcome",
                       "+*html_message" => "Welcome {{_self|name}}"
                     }
      end
      Mail::TestMailer.deliveries.clear
      @signup = Card.create! name: "Big Bad Sheep",
                             type_id: Card::SignupID,
                             "+*account" => {
                               "+*email" => "sheep@wagn.org",
                               "+*password" => "sheep"
                             }
    end

    it "sends welcome email when account is activated" do
      # @signup.run_phase :approve do
      @signup.activate_account
      # end
      @mail = ActionMailer::Base.deliveries.find { |a| a.subject == "welcome" }
      Mail::TestMailer.deliveries.clear

      expect(@mail).to be_truthy
      expect(@mail.body.raw_source).to include("Welcome Big Bad Sheep")
    end
  end

  context "invitation" do
    before do
      # NOTE:
      # by default Anonymous does not have permission to create User cards.
      Card::Auth.current_id = Card::WagnBotID
      @signup = Card.create! name: "Big Bad Wolf", type_id: Card::SignupID,
                             "+*account" => { "+*email" => "wolf@wagn.org" }
      @account = @signup.account
    end

    it "creates all the necessary cards, but no password" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@wagn.org")
      expect(@account.status).to eq("pending")
      expect(@account.salt).not_to eq("")
      expect(@account.token).to be_present
      expect(@account.password).not_to be_present
    end
  end

  # describe '#signup_notifications' do
  #   before do
  #     Card::Auth.as_bot do
  #       Card.create! name: '*request+*to', content: 'signups@wagn.org'
  #     end
  #     @user_name = 'Big Bad Wolf'
  #     @user_email = 'wolf@wagn.org'
  #     @signup = Card.create! name: @user_name, type_id: Card::SignupID,
  #                            '+*account'=>{
  #       '+*email'=>@user_email, '+*password'=>'wolf'}
  #     ActionMailer::Base.deliveries = []
  #     @signup.signup_notifications
  #     @mail = ActionMailer::Base.deliveries.last
  #   end
  #
  #   it 'send to correct address' do
  #     expect(@mail.to).to eq(['signups@wagn.org'])
  #   end
  #
  #   it 'contains request url' do
  #      expect(@mail.body.raw_source).to include(card_url(@signup))
  #   end
  #
  #   it 'contains user name' do
  #     expect(@mail.body.raw_source).to include(@user_name)
  #   end
  #
  #   it 'contains user email' do
  #     expect(@mail.body.raw_source).to include(@user_email)
  #   end
  # end
end
