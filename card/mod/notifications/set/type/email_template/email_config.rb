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
