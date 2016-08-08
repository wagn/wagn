# -*- encoding : utf-8 -*-

describe Card::Set::Type::EmailTemplate do
  before :each do
    Card::Auth.as_bot do
      Card.create! name: "mail template",  type_code: "email_template",
                   subcards: {
                     "+*html message" => {
                       content: "Hi Joe! My name is {{_self|name}}"
                     },
                     "+*to" => { content: "joe@user.com" },
                     "+*from" => { content: "from@user.com" }
                   }
    end
  end
  it "sends email on update" do
    Card::Auth.as_bot do
      Card.create! name: "mail test+*self+*on update", type_code: :pointer,
                   content: "[[mail template]]"
    end
    card = Card.fetch "mail test"
    expect { Card::Auth.as_bot { card.update_attributes(content: "test") } }
      .to change { Mail::TestMailer.deliveries.count }.by(1)
  end

  it "sends email on delete" do
    Card::Auth.as_bot do
      Card.create! name: "mail test+*self+*on delete", type_code: :pointer,
                   content: "[[mail template]]"
    end
    card = Card.fetch "mail test"
    expect { Card::Auth.as_bot { card.delete } }
      .to change { Mail::TestMailer.deliveries.count }.by(1)
  end

  it "sends email on create" do
    Card::Auth.as_bot do
      Card.create! name: "Cardtype A+*type+*on create", type_code: :pointer,
                   content: "[[mail template]]"
    end
    expect do
      Card::Auth.as_bot { Card.create! name: "mailme", type_code: :cardtype_a }
    end.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "#send_action_mails" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "another mail template",
                     type_code: "email_template",
                     subcards: {
                       "+*html message" => {
                         content: "Hi Joe! My name is {{_self|name}}"
                       },
                       "+*to" => { content: "joe@user.com" },
                       "+*from" => { content: "from@user.com" }
                     }
        Card.create! name: "mail test+*self+*on update", type_code: :pointer,
                     content: "[[mail template]]\n[[another mail template]]"
        Card.create! name: "mail test+*self+*on delete", type_code: :pointer,
                     content: "[[mail template]]\n[[another mail template]]"
      end
      card = Card.fetch "mail test"
      ActionMailer::Base.deliveries = []
      card.send_action_mails on: :update
    end

    it "delivers all emails for given action" do
      expect(ActionMailer::Base.deliveries.size).to eq(2)
    end
    it "uses correct context" do
      expect(ActionMailer::Base.deliveries.last.body.raw_source)
        .to include("My name is mail test")
    end
  end

  # describe '#send_timer_mails' do
  #    before do
  #      ActionMailer::Base.deliveries = []
  #      Card::Auth.as_bot do
  #        Card.create! name: "A+*hourly", type_code: 'email_template',
  #           subcards: {
  #              '+*message'=>{content: 'hourly update name:{{_self|name}}'},
  #                     '+*to'=>{content: 'joe@user.com'},
  #                     '+*from'=>{content: 'from@user.com'}}
  #      end
  #      Card::Set::All::Observer.send_timer_mails :hourly
  #      @mail = ActionMailer::Base.deliveries.last
  #    end
  #
  #    it 'delivers hourly mails' do
  #      expect(@mail.body.raw_source).to include('hourly update')
  #    end
  #    it 'uses correct context' do
  #      expect(@mail.body.raw_source).to include('name:A')
  #    end
  #  end
end
