# -*- encoding : utf-8 -*-

class AddEmailCards < Card::CoreMigration
  def up
    # change notification rules
    %w(create update delete).each do |action|
      Card.create! name: "*on #{action}", type_code: :setting, codename: "on_#{action}"
      Card.create! name: "*on #{action}+*right+*help", content: "Configures email to be sent when card is #{action}d."
      Card.create! name: "*on #{action}+*right+*default", type_code: :pointer
    end

    # change email address list fields to pointers
    [:to, :from, :cc, :bcc].each do |field|
      set = Card[field].fetch(trait: :right, new: {})
      default_rule = set.fetch(trait: :default, new: {})
      default_rule.type_id = Card::PointerID
      default_rule.save!

      Card.search(right: { codename: field.to_s }).each do |field_card|
        field_card.update_attributes! type_id: Card::PointerID
      end

      options_rule = set.fetch(trait: :options, new: { type_code: :search_type })
      options_rule.type_id = Card::SearchTypeID
      options_rule.content = %( { "right_plus":{"codename":"account"} } )
      options_rule.save!
    end

    # create new cardtype for email templates
    Card.create! name: "Email template", codename: :email_template, type_id: Card::CardtypeID
    Card.create! name: "Email template+*type+*structure", content: %(
{{+#{Card[:from].name} | labeled | link}}
{{+#{Card[:to].name} | labeled | link}}
{{+#{Card[:cc].name} | labeled | link}}
{{+#{Card[:bcc].name} | labeled | link}}
{{+*subject | titled}}
{{+*html message | titled}}
{{+*text message | titled}}
{{+*attach | titled}}
)

    c = Card.fetch "*message", new: {}
    c.name     = "*html message"
    c.codename = "html_message"
    c.save!

    Card.create! name: "*text message", codename: "text_message"
    Card.create! name: "*text message+*right+*default", type_code: :plain_text

    Card::Cache.reset_all

    # create system email cards
    dir = File.join data_path, "mailer"
    json = File.read(File.join(dir, "mail_config.json"))
    data = JSON.parse(json)
    data.each do |mail|
      mail = mail.symbolize_keys!
      Card.create! name: mail[:name], codename: mail[:codename], type_id: Card::EmailTemplateID
      Card.create! name: "#{mail[:name]}+*html message", content: File.read(File.join(dir, "#{mail[:codename]}.html"))
      Card.create! name: "#{mail[:name]}+*text message", content: File.read(File.join(dir, "#{mail[:codename]}.txt"))
      Card.create! name: "#{mail[:name]}+*subject", content: mail[:subject]
    end

    # move old hard-coded signup alert email handling to new card-based on_create handling
    Card.create!(
      name: ([:signup, :type, :on_create].map { |code| Card[code].name } * "+"),
      type_id: Card::PointerID, content: "[[signup alert email]]"
    )
    if request_card = Card[:request]
      [:to, :from].each do |field|
        if old_card = request_card.fetch(trait: field) && !old_card.content.blank?
          Card.create! name: "signup alert email+#{Card[field].name}", content: old_card.content
        end
      end
      request_card.codename = nil
      request_card.delete!
    end

    # update *from settings

    signup_alert_from = Card["signup alert email"].fetch(trait: :from, new: {})
    if signup_alert_from.content.blank?
      signup_alert_from.content = "_user"
      signup_alert_from.save!
    end

    wagn_bot = Card[:wagn_bot].account.email.present? ? Card[:wagn_bot].name : nil
    token_emails_from = Card.global_setting("*invite+*from") || wagn_bot || "_user"
    ["verification email", "password reset email"].each do |token_email_template_name|
      Card.create! name: "#{token_email_template_name}+#{Card[:from].name}", content: token_emails_from
    end

    if invite_card = Card[:invite]
      invite_card.codename = nil
      invite_card.delete!
    end

    # migrate old flexmail cards

    if email_config_card = Card["email_config"]
      Card.search(
        left: { type_id: Card::SetID },
        right: "email_config",
        referred_to_by: { right: { codename: "send" } }
      ).each do |card|
        set_name = card.cardname.left
        card.name = "#{set_name.tr('*', '').tr('+', '_')}_email_template"
        card.type = "Email Template"
        card.save!
        Card.create! name: "#{set_name}+*on create", content: card.name
      end

      email_config_card.delete!
    end

    # the new following rule
    Card.create! name: "*following", type_code: :pointer, codename: "following"

    send = Card[:send]
    return unless send
    send.update_attributes codename: nil
    send.delete!
  end
end
