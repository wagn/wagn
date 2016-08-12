# -*- encoding : utf-8 -*-
require "card/mailer"

describe Card::Set::Type::EmailTemplate do
  let(:email_name) { "a mail template" }
  let(:email) { Card.fetch(email_name) }

  def mailconfig args={}
    Card[email_name].email_config(args)
  end

  def update_field name, args={}
    Card["#{email_name}+#{name}"].update_attributes! args
  end

  def create_field name, args={}
    Card.create! args.merge(name: "#{email_name}+#{name}")
  end

  before do
    Card::Auth.current_id = Card::WagnBotID
    chunk_test = "Url(wagn.org) Link([[http://wagn.org|Wagn]])"\
                 " Inclusion({{B|name}}) Card link([[A]])"
    Card.create! name: email_name, type: :email_template, subcards: {
      "+*to"           =>  "joe@user.com",
      "+*from"         =>  "from@user.com",
      "+*subject"      =>  "*subject #{chunk_test}",
      "+*html_message" =>  "*html message #{chunk_test}",
      "+*text_message" =>  "*text message #{chunk_test}"
    }
  end

  describe "mail view" do
    let(:content_type) do
      card = Card.create!(name: "content type test", type: :email_template,
                          subcards: @fields)
      email = card.format.render_mail
      email[:content_type].value
    end

    it "renders text email if text message given" do
      @fields = { "+*text_message" => "text" }
      expect(content_type).to include "text/plain"
    end

    it "renders html email if html message given" do
      @fields = { "+*html_message" => "text" }
      expect(content_type).to include "text/html"
    end

    it "renders multipart email if text and html given" do
      @fields = { "+*text_message" => "text", "+*html_message" => "text" }
      expect(content_type).to include "multipart/alternative"
    end
  end

  describe "#email_config" do
    describe "address fields" do
      it "uses *from field" do
        expect(mailconfig[:from]).to eq "from@user.com"
      end

      it "uses *to field" do
        expect(mailconfig[:to]).to eq "joe@user.com"
      end

      it "handles pointer values" do
        create_field "*cc", content: "[[joe@user.com]]", type: "Pointer"
        expect(mailconfig[:cc]).to eq "joe@user.com"
      end

      # it 'handles email syntax in pointer values' do
      #  create_field '*cc', content: "[[Joe User <joe@user.com>]]",
      #                      type: 'Pointer'
      #  expect( mailconfig[:cc] ).to eq 'Joe User <joe@user.com>'
      # end

      it "handles link to email card" do
        create_field "*cc", content: "[[Joe User+*email]]", type: "Pointer"
        expect(mailconfig[:cc]).to eq "joe@user.com"
      end

      # it 'handles link with valid email address' do
      #   create_field '*cc', content: "[[joe@admin.com|Joe]]", type: 'Phrase'
      #   expect( mailconfig[:cc] ).to eq 'Joe<joe@user.com>'
      # end

      it "handles search card" do
        create_field "*bcc", content: '{"name":"Joe Admin","append":"*email"}',
                             type: "Search"
        expect(mailconfig[:bcc]).to eq "joe@admin.com"
      end
      # TODO: not obvious how to deal with that.
      # it 'handles invalid email address' do
      #      we can't decided whether a email address like [[_left]] is valid;
      #      depends on the context
      #   Card.fetch("a mail template+*to").
      #     update_attributes(content: "invalid mail address")
      # end
    end

    describe "subject" do
      subject { mailconfig[:subject] }

      it "uses *subject field" do
        is_expected.to include "*subject"
      end
      it "does not render url" do
        is_expected.to include "Url(wagn.org)"
      end
      it "does not render link" do
        is_expected.to include "Link([[http://wagn.org|Wagn]])"
      end
      it "renders nest" do
        is_expected.to include "Inclusion(B)"
      end
    end

    describe "text message" do
      subject { mailconfig[:text_message] }

      it "uses *text_message field" do
        is_expected.to include "*text message"
      end
      it "does not render url" do
        is_expected.to include "Url(wagn.org)"
      end
      it "renders link" do
        is_expected.to include "Link(Wagn[http://wagn.org])"
      end
      it "renders nest" do
        is_expected.to include "Inclusion(B)"
      end
    end

    describe "html message" do
      subject { mailconfig[:html_message] }

      it "uses *html_message field" do
        is_expected.to include "*html message"
      end
      it "renders url" do
        is_expected.to include 'Url(<a target="_blank" class="external-link" '\
                               'href="http://wagn.org">wagn.org</a>)'
      end
      it "renders link" do
        is_expected.to include 'Link(<a target="_blank" class="external-link" '\
                               'href="http://wagn.org">Wagn</a>)'
      end
      it "renders nest" do
        is_expected.to include "Inclusion(B)"
      end
      it "renders absolute urls" do
        Card::Env[:protocol] = "http://"
        Card::Env[:host] = "www.fake.com"
        is_expected.to include 'Card link(<a class="known-card" '\
                               'href="http://www.fake.com/A">A</a>)'
      end
    end

    context "with context card" do
      let(:context_card) do
        file = File.new(File.join FIXTURES_PATH, "mao2.jpg")
        Card.create(
          name:    "Banana",
          content: "data content [[A]]",
          subcards: {
            "+email" => { content: "gary@gary.com" },
            "+subject" => { type: "Pointer", content: "[[default subject]]" },
            "+attachment" => { type: "File", file: file }
          }
        )
      end
      subject {  mailconfig(context: context_card) }

      it "handles contextual name in address search" do
        update_field "*from", content: '{"left":"_self", "right":"email"}',
                              type: "Search"
        expect(subject[:from]).to eq "gary@gary.com"
      end

      it "handles contextual names and structure rules in subject" do
        Card.create! name: "default subject", content: "a very nutty thang",
                     type: "Phrase"
        Card.create! name: "subject search+*right+*structure",
                     content: %({"referred_to_by":"_left+subject"}),
                     type: "Search"
        update_field "*subject", content: "{{+subject search|core;item:core}}"
        expect(subject[:subject]).to eq("a very nutty thang")
      end

      it "handles _self in html message" do
        update_field "*html message", content: "Triggered by {{_self|name}}"
        expect(subject[:html_message]).to include("Triggered by Banana")
      end

      it "handles _left in html message" do
        update_field "*html_message",
                     content: "Nobody expects {{_left+surprise|core}}"
        Card.create name: "Banana+surprise", content: "the Spanish Inquisition"
        c = Card.create name: "Banana+emailtest", content: "data content"
        expected = mailconfig(context: c)[:html_message]
        expect(expected).to include "Nobody expects the Spanish Inquisition"
      end

      it "handles contextual name for attachments" do
        create_field "*attach", type: "Pointer", content: "[[_self+attachment]]"
        expect(subject[:attach]).to eq ["Banana+attachment".to_name]
      end
    end
  end
end
