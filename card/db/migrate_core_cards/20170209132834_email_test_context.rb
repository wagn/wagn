# -*- encoding : utf-8 -*-

class EmailTestContext < Card::Migration::Core
  def up
    ensure_card "*test context",
                codename: :test_context
    ensure_card "*changed card",
                codename: :changed_card
    ensure_card "*test context+*right+*default",
                type_id: Card::PointerID
    Card::Cache.reset_all

    { verification_email: "Wagn Bot+*account",
      password_reset_email: "Wagn Bot+*account",
      signup_alert_email: "User",
      follower_notification_email: "*changed card",
      "welcome email" => "User" }.each do |template, content|
      add_test_context template, content
    end

    update_follower_notification_template
  end

  def update_follower_notification_template
    dir = File.join data_path, "mailer"
    name = "follower notification email"
    codename = "follower_notification_email"
    update_if_unchanged "#{name}+*html message",
                        File.read(File.join(dir, "#{codename}.html"))
    update_if_unchanged "#{name}+*text message",
                        File.read(File.join(dir, "#{codename}.txt"))
    update_if_unchanged "#{name}+*subject",
                        "{{_user|name}} {{_|last_action_verb}} \"{{_|name}}\""
  end

  def update_if_unchanged name, content
    return if (card = Card[name]) && card.updater.codename != "wagn_bot"
    ensure_card name, content: content
  end

  def add_test_context email_template, content
    return unless Card[email_template]
    ensure_card [email_template, :test_context],
                content: content,
                type_id: Card::PointerID
  end
end
