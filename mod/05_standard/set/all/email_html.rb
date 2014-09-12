
format :email do
  def deliver args={}
    _render_mail(args).deliver
  end
    
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end

  view :raw do |args| 
    output = card.raw_content
    if args[:locals]
      args[:locals].each do |key, value|
        output.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)  # this should happen in a special format/render combination
        instance_variable_set "@#{key}", value
      end
    end
    ERB.new(output).result(binding) 
  end
  
  view :mail do |args|
    ActionMailer::Base.mail _render_config( args )   #TODO add error handling
  end
  
  view :change_notice do |args|    
    cd_with_acct = Card[args[:watcher]] unless Card===args[:watcher]
    email = cd_with_acct.account.email
    updated_card = args[:updated_card] || card
    Card['change notice'].format(:format=>:email)._render_mail(   #TODO get card from a rule?
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
    if attachment_list = config.delete(:attach) and !attachment_list.empty?
      attachment_list.each_with_index do |cardname, i|
        if c = Card[ cardname ] and c.respond_to?(:attach)
          attachments["attachment-#{i + 1}.#{c.attach_extension}"] = File.read( c.attach.path )
        end
      end
    end
    [:subject, :message].each do |field|
      config[field] = args[field] || begin
        config[field] = ( fld_card=Card["#{card.name}+*#{field}"] ).nil? ? '' :
            Auth.as( fld_card.updater ) do
              fld_card.contextual_content context_card, {:format=>'email_html'}, args
            end
      end
    end
    config[:body] ||= Card::Mailer.layout(config.delete(:message))
    config[:subject] = strip_html(config[:subject]).strip if config[:subject]
    config[:content_type] ||= 'text/html'
    config
  end
  
  def strip_html string
    string.gsub(/<\/?[^>]*>/, "")
  end
end
