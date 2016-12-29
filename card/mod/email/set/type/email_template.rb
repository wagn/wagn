
def clean_html?
  false
end

def deliver args={}
  mail = format.render_mail(args)
  mail.deliver
rescue Net::SMTPError => exception
  errors.add :exception, exception.message
end

def process_html_message config, args, inline_attachment_url
  process_message_field(
    :html_message, config,
    args.merge(inline_attachment_url: inline_attachment_url),
    "email_html"
  )
  if config[:html_message].present?
    config[:html_message] = Card::Mailer.layout config[:html_message]
  end
  config
end

format do
  view :mail, perms: :none, cache: :never do |args|
    config = card.email_config(args)
    text_message = config.delete(:text_message)
    attachment_list = config.delete(:attach)
    email_card = card # card is not accessible in the new_mail block
    mail = Card::Mailer.new_mail(config) do
      # inline attachments only work in the binding of this block
      # so the current solution is to create a lambda here and pass it
      # to the view where it is needed to create the image tag
      # (see core view in Type::Image::EmailHtmlFormat)
      inline_attachment_url =
        lambda do |path|
          attachments.inline[path] = ::File.read path
          attachments[path].url
        end
      email_card.process_html_message config, args, inline_attachment_url
      html_message = config.delete(:html_message)
      alternative = (text_message.present? && html_message.present?)

      if alternative
        if attachment_list && !attachment_list.empty?
          content_type "multipart/mixed"
          part content_type: "multipart/alternative" do |copy|
            copy.part content_type: "text/plain" do |plain|
              plain.body = text_message
            end
            copy.part content_type: "text/html" do |html|
              html.body = html_message
            end
          end
        else
          text_part { body text_message }
          html_part do
            content_type "text/html; charset=UTF-8"
            body html_message
          end
        end
      elsif html_message.present?
        content_type "text/html; charset=UTF-8"
        body html_message
      else
        content_type "text/plain; charset=UTF-8"
        text_part { body text_message }
      end

      if attachment_list
        attachment_list.each_with_index do |cardname, i|
          if (c = Card[cardname]) && c.respond_to?(:attachment)
            add_file filename: "attachment-#{i + 1}.#{c.attachment.extension}",
                     content: File.read(c.attachment.path)
          end
        end
      end
    end  # TODO: add error handling
    mail
  end
end
