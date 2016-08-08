# -*- encoding : utf-8 -*-

class FixNotificationHtmlMessage < Card::CoreMigration
  def up
    codename = :follower_notification_email
    dir = File.join data_path, "mailer"
    html_message = Card[codename].fetch trait: "html_message"
    html_message.update_attributes! content: File.read(File.join(dir, "#{codename}.html"))
  end
end
