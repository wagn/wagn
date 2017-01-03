# -*- encoding : utf-8 -*-
require "card/mailer"

describe Card::Set::Type::EmailTemplate do
  describe "view :mail" do
    let(:content_type) do
      Card::Auth.current_id = Card::WagnBotID
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
end
