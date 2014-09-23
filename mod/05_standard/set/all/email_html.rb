format :email do
  
  def deliver args={}
    mail = _render_mail(args)
    mail.delivery_method(Wagn.config.action_mailer.delivery_method,Wagn.config.action_mailer.smtp_settings)
    mail.deliver
  end
    
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end

  view :raw do |args| 
    output = card.raw_content
    if args[:locals]
      args[:locals].each do |key, value|
        output.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
        #instance_variable_set "@#{key}", value
      end
    end
    output
  end
    
  
  view :mail do |args|      
    args = email_config(args)
    text_message = args.delete(:text_message)
    html_message = args.delete(:html_message)
    attachment_list = args.delete(:attach)
    alternative = text_message.present? and html_message.present?
    
    mail = Mail.new(args) do
      if alternative and attachment and !attachment_list.empty?
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
        text_part do
          body text_message
        end

        html_part do
          content_type 'text/html; charset=UTF-8'
          body html_message
        end
      end  
      if attachment_list
        attachment_list.each_with_index do |cardname, i|
          if c = Card[ cardname ] and c.respond_to?(:attach)
            add_file :filename => "attachment-#{i + 1}.#{c.attach_extension}", :content => File.read( c.attach.path )
          end
        end
      end
    end   #TODO add error handling
  end
    
  
  def email_config args={}
    config = {}
    args[:locals] ||= {}
    args[:locals][:site] = Card.setting :title
    context_card = args[:context] || card
    [:to, :from, :cc, :bcc, :attach].each do |field|
      config[field] = args[field] || begin 
        ( fld_card = Card["#{card.name}+*#{field}"] ).nil? ? '' :
              # configuration can be anything visible to configurer
              Auth.as( fld_card.updater ) do
                list = fld_card.extended_item_contents context_card
                field == :attach ? list : list * ','
              end
        end
    end
    [:subject, :message, :html_message, :text_message].each do |field|
      config[field] = args[field] || begin
        config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
            Auth.as( fld_card.updater ) do
              fld_card.contextual_content context_card, {:format=>'email_html'}, args
            end
      end
    end
    if !config[:html_message].present?
      config[:html_message] = config[:message]
    end
    config.delete(:message)
    config[:html_message] = Card::Mailer.layout(config[:html_message])
    config[:from] ||= Card[Card::WagnBotID].account.email
    config[:subject] = strip_html(config[:subject]).strip if config[:subject]
    config.select {|k,v| v.present? }
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end
