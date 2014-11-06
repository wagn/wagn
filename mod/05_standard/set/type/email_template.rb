def clean_html?
  false
end

def deliver args={}
  mail = format.render_mail(args)
#  mail.from = Auth.current.account.email unless mail.from
  mail.deliver 
end

format do     
  view :mail do |args|
    args = email_config(args)
    text_message = args.delete(:text_message)
    html_message = args.delete(:html_message)
    attachment_list = args.delete(:attach)
    alternative = text_message.present? and html_message.present?
    mail = Mail.new(args) do
      if alternative 
        if attachment and !attachment_list.empty?
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
      else
        content_type 'text/html; charset=UTF-8'
        body html_message
      end
      if attachment_list
        attachment_list.each_with_index do |cardname, i|
          if c = Card[ cardname ] and c.respond_to?(:attach)
            add_file :filename => "attachment-#{i + 1}.#{c.attach_extension}", :content => File.read( c.attach.path )
          end
        end
      end
      method = Card::Mailer.delivery_method
      delivery_method(method, Card::Mailer.send(:"#{method}_settings"))
    
    end   #TODO add error handling
#    mail.perform_deliveries    = Card::Mailer.perform_deliveries
    mail.raise_delivery_errors = Card::Mailer.raise_delivery_errors
    mail
  end
  
  def process_email_field field, args, joint=nil
    if args[field] 
      args[field]
    elsif field_card = card.fetch(:trait=>field)
      # configuration can be anything visible to configurer
      Auth.as( field_card.updater ) do
        res = field_card.send(*yield)
        joint ? res.join(joint) : res
      end
    else 
      ''
    end
  end
  
  def email_config args={}
    config = {}
    context_card = args[:context] || card
  
    [:to, :from, :cc, :bcc].each do |field_name|
      config[field_name] = process_email_field( field_name, args, ',' ) do 
        [:extended_item_contents, context_card]
      end
    end
  
    config[:attach] = process_email_field( :attach, args ) do 
        [:extended_item_contents, context_card]
      end
  
    [:subject, :html_message].each do |field_name|
      config[field_name] = process_email_field( field_name, args ) do 
        [:contextual_content, context_card, {:format=>'email_html'}, args]
      end
    end
  
    config[:text_message] = process_email_field :text_message, args do
      [:contextual_content, context_card, {:format=>'email_text'}, args]
    end
  
    config[:html_message] = Card::Mailer.layout(config[:html_message])
    config[:from] ||= Card[Card::WagnBotID].account.email
    config[:subject] = strip_html(config[:subject]).strip if config[:subject]
    config.select {|k,v| v.present? }
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end