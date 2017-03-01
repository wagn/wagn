# -*- encoding : utf-8 -*-
require "card/mailer"

describe Card::Set::Type::EmailTemplate::EmailConfig do
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
      "+*to" => "joe@user.com",
      "+*from" => "from@user.com",
      "+*subject" => "*subject #{chunk_test}",
      "+*html_message" => "*html message #{chunk_test}",
      "+*text_message" => "*text message #{chunk_test}"
    }
  end
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
      is_expected.to include "Link(Wagn[http://wagn.org])"
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
    subject do
      config = mailconfig
      config[:context] = Card[email_name]
      config =
        Card[email_name].process_html_message(config,
                                              { context: Card[email_name] },
                                              nil)
      # TODO: very hacky to test this; screams for refactoring
      config[:html_message]
    end

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
    subject(:config) { mailconfig(context: context_card) }
    let(:context_card) do
      file = File.new(File.join(FIXTURES_PATH, "mao2.jpg"))
      Card.create(
        name: "Banana",
        content: "data content [[A]]",
        subcards: {
          "+email" => { content: "gary@gary.com" },
          "+subject" => { type: "Pointer", content: "[[default subject]]" },
          "+attachment" => { type: "File", file: file }
        }
      )
    end

    it "handles contextual name in address search" do
      update_field "*from", content: '{"left":"_self", "right":"email"}',
                            type: "Search"
      expect(config[:from]).to eq "gary@gary.com"
    end

    it "handles contextual names and structure rules in subject" do
      Card.create! name: "default subject", content: "a very nutty thang",
                   type: "Phrase"
      Card.create! name: "subject search+*right+*structure",
                   content: %({"referred_to_by":"_left+subject"}),
                   type: "Search"
      update_field "*subject", content: "{{+subject search|core|core}}"
      expect(config[:subject]).to eq("a very nutty thang")
    end

    it "handles _self in html message" do
      update_field "*html message", content: "Triggered by {{_self|name}}"
      mail = email.format.render_mail context: context_card
      expect(mail.parts[1].body.raw_source).to include("Triggered by Banana")
    end

    it "handles _left in html message" do
      update_field "*html_message",
                   content: "Nobody expects {{_left+surprise|core}}"
      Card.create name: "Banana+surprise", content: "the Spanish Inquisition"
      c = Card.create name: "Banana+emailtest", content: "data content"
      mail = email.format.render_mail context: c
      # c.format.render_mail.parts[1].body.raw_source
      expected = mail.parts[1].body.raw_source
      # expected = mailconfig(context: c)[:html_message]
      expect(expected).to include "Nobody expects the Spanish Inquisition"
    end

    it "handles inline image nests in html message  in core view" do
      Card::Env[:host] = "http://testhost"
      update_field "*html message", content: "Triggered by {{:logo|core}}"
      mail = email.format.render_mail context: context_card
      expect(mail.parts.size).to eq 2
      expect(mail.parts[0].mime_type).to eq "text/plain"
      expect(mail.parts[1].mime_type).to eq "text/html"
      expect(mail.parts[1].body.raw_source)
        .to include('<img src="http://testhost/files/:logo/standard-medium.png"')
    end

    it "handles inline image nests in html message" do
         update_field "*html message", content: "Triggered by {{:logo|inline}}"
         mail = email.format.render_mail context: context_card
         expect(mail.parts[0].mime_type).to eq "image/png"
         url = mail.parts[0].url
         expect(mail.parts[2].mime_type).to eq "text/html"
         expect(mail.parts[2].body.raw_source).to include('<img src="cid:')
         expect(mail.parts[2].body.raw_source).to include("<img src=\"#{url}\"")
       end

    it "handles image nests in html message in default view" do
      update_field "*html message", content: "Triggered by {{:logo|core}}"
      mail = email.format.render_mail context: context_card
      expect(mail.parts.size).to eq 2
      expect(mail.parts[0].mime_type).to eq "text/plain"
      expect(mail.parts[1].mime_type).to eq "text/html"
      expect(mail.parts[1].body.raw_source)
        .to include('<img src="/files/:logo/standard-medium.png"')
    end

    it "handles contextual name for attachments" do
      create_field "*attach", type: "Pointer", content: "[[_self+attachment]]"
      expect(config[:attach]).to eq ["Banana+attachment".to_name]
    end
  end
end
