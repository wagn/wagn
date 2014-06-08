
format :email do
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end

  view :raw do |args| 
    output = card.raw_content
    args[:locals].each do |key, value|
      output.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
      instance_variable_set "@#{key}", value
    end
    config[field] = ERB.new(output).result(binding)  #FIXME run always ERB ???
  end
  
  view :mail do |args|
    mail _render_config( args )
    #card.mail_layout args
  end

  view :config do |args|
    config = {}

    [:to, :from, :cc, :bcc, :attach].each do |field|
      if args[field]
        config[field] = args[field]
      else
        config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
            # configuration can be anything visible to configurer
            Auth.as( fld_card.updater ) do
              list = fld_card.extended_list card
              field == :attach ? list : list * ','
            end
      end
    end
    
    #config sender
    if default_from=Card::Mailer.default[:from]
      from_name, from_email = (config[:from] =~ /(.*)\<(.*)>/) ? [$1.strip, $2] : [nil, config[:from]]
      config[:from] = !from_email ? default_from : "#{from_name || from_email} <#{default_from}>"
      config[:reply_to] ||= config[:from]
    end
    
    args[:locals] ||= {}
    args[:locals][:site] = Card.setting :title
    
    [:subject, :message].each do |field|
      if args[field]
          config[field] = args[field]
      else
       # fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
 #            Auth.as( fld_card.updater ) do
 #              fld_card.contextual_content card, :format=>:email
 #            end
        config[field] = (fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
          Auth.as( fld_card.updater ) do
              fld_card.format(:format=>:email).render_core args
          end
        
        # content = Card.fetch( "#{card.name}+#{field.to_s}", :new => {} ).content  #FIXME work with codenames?
        # args[:locals].each do |key, value|
        #   content.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
        #   instance_variable_set "@#{key}", value
        # end
        # config[field] = ERB.new(content).result(binding)  #FIXME run always ERB ???
      end
    end
    config[:subject] = strip_html(config[:subject]).strip
    if args[:layout].present?
      
    end
    config[:body] ||= config[:message]
    config[:content_type] ||= 'text/html'
    config
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end
