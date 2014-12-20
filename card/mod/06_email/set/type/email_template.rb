def clean_html?
  false
end

def deliver args={}
  begin
    mail = format.render_mail(args)
    mail.deliver 
  rescue Net::SMTPError => exception
    errors.add :exception, exception.message 
  end
end

def process_email_field field, args
  if args[field] 
    args[field]
  elsif field_card = fetch(:trait=>field)
    # configuration can be anything visible to configurer
     user = ( args[:follower] and Card.fetch(args[:follower]) ) || field_card.updater
     Auth.as( user ) do
       yield(field_card)
    end
  else 
    ''
  end
end



def email_config args={}
  config = {}
  context_card = args[:context] || self

  [:to, :from, :cc, :bcc].each do |field_name|
    config[field_name] = process_email_field( field_name, args ) do |field_card|
      field_card.process_email_addresses context_card, {:format=>'email_text'}, args
    end
  end

  config[:attach] = process_email_field( :attach, args ) do |field_card|
      field_card.extended_item_contents context_card
    end
  
  [:subject, :text_message].each do |field_name|
    config[field_name] = process_email_field( field_name, args ) do |field_card|
      field_card.contextual_content context_card, {:format=>'email_text'}, args
    end
  end

  config[:html_message] = process_email_field :html_message, args do |field_card|
    field_card.contextual_content context_card, {:format=>'email_html'}, args
  end

  config[:html_message] = Card::Mailer.layout(config[:html_message])

  from_name, from_email = (config[:from] =~ /(.*)\<(.*)>/) ? [$1.strip, $2] : [nil, config[:from]]

  if default_from=Card::Mailer.default[:from]
    config[:from] = from_email ? "#{from_name || from_email} <#{default_from}>" : default_from
    config[:reply_to] ||= config[:from]
  else
    config[:from] ||= Card[Card::WagnBotID].account.email
  end
  config.select {|k,v| v.present? }
end


format do     
  view :mail do |args|
    args = card.email_config(args)
    text_message = args.delete(:text_message)
    html_message = args.delete(:html_message)
    attachment_list = args.delete(:attach)
    alternative = text_message.present? and html_message.present?
    mail = Card::Mailer.new_mail(args) do
      if alternative 
        if attachment_list and !attachment_list.empty?
          content_type 'multipart/mixed'
          part :content_type => 'multipart/alternative' do |copy|
            copy.part :content_type => 'text/plain' do |plain|
              plain.body = text_message
            end
            copy.part :content_type => 'text/html' do |html|
              html.body = html_message
            end
          end    
        else
          text_part { body text_message }
          html_part do
            content_type 'text/html; charset=UTF-8'
            body html_message
          end
        end
      elsif html_message.present?
        content_type 'text/html; charset=UTF-8'
        body html_message
      else
        text_part { body text_message }
      end
      
      if attachment_list
        attachment_list.each_with_index do |cardname, i|
          if c = Card[ cardname ] and c.respond_to?(:attach)
            add_file :filename => "attachment-#{i + 1}.#{c.attach_extension}", :content => File.read( c.attach.path )
          end
        end
      end    
    end   #TODO add error handling
    mail
  end
  
end
