
def clean_html?
  false
end

def deliver args={}
  mail = format.render_mail(args)
  mail.deliver
rescue Net::SMTPError => exception
  errors.add :exception, exception.message
end

def process_email_field field, config, args
  config[field] =
    if args[field]
      args[field]
    elsif (field_card = fetch(trait: field))
      # configuration can be anything visible to configurer
      user = (args[:follower] && Card.fetch(args[:follower])) ||
             field_card.updater
      Auth.as(user) do
        yield(field_card)
      end
    else
      ""
    end
end

def process_message_field field, config, args, format, special_args=nil
  process_email_field(field, config, args) do |field_card|
    content_args = args.clone
    content_args.merge! special_args if special_args
    field_card.contextual_content args[:context], { format: format },
                                  content_args
  end
end

def email_config args={}
  config = {}
  args[:context] ||= self

  [:to, :from, :cc, :bcc].each do |field_name|
    process_email_field(field_name, config, args) do |field_card|
      field_card.process_email_addresses(
        args[:context], { format: "email_text" }, args
      )
    end
  end
  process_email_field(:attach, config, args) do |field_card|
    field_card.extended_item_contents args[:context]
  end
  process_message_field :subject, config, args, "email_text",
                        content_opts: { chunk_list: :nest_only }
  process_message_field :text_message, config, args, "email_text"
  process_message_field :html_message, config, args, "email_html"
  if config[:html_message].present?
    config[:html_message] = Card::Mailer.layout config[:html_message]
  end

  from_name, from_email =
    if config[:from] =~ /(.*)\<(.*)>/
      [Regexp.last_match(1).strip, Regexp.last_match(2)]
    else
      [nil, config[:from]]
    end

  if (default_from = Card::Mailer.default[:from])
    config[:from] =
      if from_email
        %("#{from_name || from_email}" <#{default_from}>)
      else
        default_from
      end
    config[:reply_to] ||= config[:from]
  elsif config[:from].blank?
    config[:from] = Card[Card::WagnBotID].account.email
  end
  config.select { |_k, v| v.present? }
end

format do
  view :mail, perms: :none do |args|
    args = card.email_config(args)
    text_message = args.delete(:text_message)
    html_message = args.delete(:html_message)
    attachment_list = args.delete(:attach)
    alternative = (text_message.present? && html_message.present?)
    mail = Card::Mailer.new_mail(args) do
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
