
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
    ActionMailer::Base.mail _render_config( args )
  end
  
  
  view :change_notice do |args|    
    cd_with_acct = Card[args[:watcher]] unless Card===args[:watcher]
    email = cd_with_acct.account.email
    updated_card = args[:updated_card] || card
    
    Card['change notice'].format(:format=>:email)._render_mail(   #FIXME get card from a rule
      :to     => email,
      :from   => Card[Card::WagnBotID].account.email,
      :locals => {
                  :name => card.name,
                  :updater => updated_card.updater.name,
                  :action => args[:action],
                  :subedits => args[:subedits],
                  :card_url => wagn_url( card ),
                  :change_url  => wagn_url( "card/changes/#{card.cardname.url_key}" ),
                  :unwatch_url => wagn_url( "card/watch/#{args[:watched].to_name.url_key}?toggle=off" ),
                  :updater_url => wagn_url( card.updater ),
                  :watched => (args[:watched] == card.cardname ? "#{args[:watched]}" : "#{args[:watched]} cards"),
                 })
  end
  
  
  view :config do |args|
    config = {}
    byebug
    [:to, :from, :cc, :bcc, :attach].each do |field|
      config[field] = args[field] || ( fld_card=Card["#{card.name}+#{field}"] ).nil? ? '' :
            # configuration can be anything visible to configurer
            Auth.as( fld_card.updater ) do
              list = fld_card.extended_item_contents card
              field == :attach ? list : list * ','
            end
    end
    byebug  
    if attachment_list = config.delete(:attach) and !attachment_list.empty?
      attachment_list.each_with_index do |cardname, i|
        if c = Card[ cardname ] and c.respond_to?(:attach)
          attachments["attachment-#{i + 1}.#{c.attach_extension}"] = File.read( c.attach.path )
        end
      end
    end
    
    args[:locals] ||= {}
    args[:locals][:site] = Card.setting :title
    
    [:subject, :message].each do |field|
      config[field] = args[field] || begin
        # config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
 #            Auth.as( fld_card.updater ) do
 #              fld_card.contextual_content card, :format=>'email_html'
 #            end
        
        if content = Card.fetch( "#{card.name}+#{field.to_s}", :new => {} ).content  #FIXME work with codenames?
          args[:locals].each do |key, value|
            content.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
            instance_variable_set "@#{key}", value
          end
          ERB.new(content).result(binding)  #FIXME run always ERB ???
        end
      end
    end
    layout_cardname = args[:layout] || Card.fetch( "#{card.name}+layout", :new => {} ).content
    if layout = Card.fetch( layout_cardname, :new => {} ).content and layout.present?
      @message = config[:message]
      config[:body] ||= ERB.new(layout).result(binding)
    else
      config[:body] ||= config[:message]
    end
    
    config[:subject] = strip_html(config[:subject]).strip if config[:subject]
    config[:content_type] ||= 'text/html'
    config
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end
