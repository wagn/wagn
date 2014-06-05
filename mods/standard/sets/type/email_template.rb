def clean_html?
  false
end


format :email do
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end

  
  view :mail do |args|
    card.flexmail args
  end

  view :config do |args|
    config = {}

    [:to, :from, :cc, :bcc, :attach].each do |field|
      if args[:field]
        config[:field] = args[:field]
      else
        config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
            # configuration can be anything visible to configurer
            Auth.as( fld_card.updater ) do
              list = fld_card.extended_list card
              field == :attach ? list : list * ','
            end
      end
    end

    args[:locals] ||= {}
    args[:locals][:site] = Card.setting :title
    
    [:subject, :message].each do |field|
      if args[:field]
          config[:field] = args[:field]
      else
        # config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
 #            Auth.as( fld_card.updater ) do
 #              fld_card.contextual_content card, :format=>'email_html'
 #            end
        
        content = Card.fetch( "#{card.name}+#{field.to_s}", :new => {} ).content  #FIXME work with codenames?
        args[:locals].each do |key, value|
          content.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
          instance_variable_set "@#{key}", value
        end
        config[field] = ERB.new(content).result(binding)  #FIXME run always ERB ???
      end
    end

    config[:subject] = strip_html(config[:subject]).strip
    config[:body] ||= config[:message]
    config[:content_type] ||= 'text/html'
    config
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end